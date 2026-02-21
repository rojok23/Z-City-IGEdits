--Shout Vote Main Server Dist
SHOUT = {}
SHOUT.CurrentVoters = {}
SHOUT.CurrentResults = {}
SHOUT.RTVPlayers = {}
SHOUT.NominatedMaps = {}
SHOUT.InProgress = false
include('sh_shoutconfig.lua')
include('sv_shoutdata.lua')
util.AddNetworkString("ShoutVote_New")
util.AddNetworkString("ShoutVote_Update")
util.AddNetworkString("ShoutVote_End")
util.AddNetworkString("ShoutVote_Shout")
util.AddNetworkString("ShoutVote_Player")
if SHOUT.Settings.EnableRTV then util.AddNetworkString("ShoutVote_RTV") end
if SHOUT.Settings.EnableNominate then 
	util.AddNetworkString("ShoutVote_Nominate")
	util.AddNetworkString("ShoutVote_NominateList")
end

function SHOUT.FindAvailableMaps()
	local AvailableMaps = {}
	local SearchedMaps = {}
	SearchedMaps = file.Find("maps/*.bsp","GAME")
	table.Add(SearchedMaps, file.Find(string.format("gamemodes/%s/content/maps/*.bsp",gmod.GetGamemode().FolderName),"GAME"))
	for k,v in pairs(SearchedMaps) do
		if SHOUT.Settings.MapPrefixes and #SHOUT.Settings.MapPrefixes > 0 then
			for l,m in pairs(SHOUT.Settings.MapPrefixes) do
				if string.StartWith(v,m) then table.insert(AvailableMaps,string.lower(string.sub(v,0,v:len() - 4))) break end
			end
		else
			table.insert(AvailableMaps,string.lower(string.sub(v,0,v:len() - 4)))
		end
	end
	--Find maps to exclude
	if SHOUT.Settings.MapRoundsCooldown and SHOUT.Settings.MapRoundsCooldown != 0 then
		SHOUT.RemoveExcludedMaps(SHOUT.Database.FindExcludedMapsByRoundsAgo(SHOUT.Settings.MapRoundsCooldown),AvailableMaps)
	end
	if SHOUT.Settings.MapLastPlayedCooldown and SHOUT.Settings.MapLastPlayedCooldown != 0 then
		SHOUT.RemoveExcludedMaps(SHOUT.Database.FindExcludedMapsByLastPlayed(SHOUT.Settings.MapLastPlayedCooldown),AvailableMaps)
	end
	if not SHOUT.Settings.EnableExtendMapOption then table.RemoveByValue(AvailableMaps, string.lower(game.GetMap())) end
	
	return AvailableMaps
end

function SHOUT.RemoveExcludedMaps(excludelist, mapslist)
	if not excludelist or not mapslist then return end
	for k,v in pairs(excludelist) do
		table.RemoveByValue(mapslist, string.lower(v.map)) 
	end
end

function SHOUT.StartNewVote(maps)
//if ply then SHOUT.EndVote(true) end 
if SHOUT.InProgress then return end
SHOUT.InProgress = true
local AvailableVoteMaps = maps or SHOUT.FindAvailableMaps()
SHOUT.CurrentMaps = {}

if SHOUT.Settings.EnableExtendMapOption and not maps then table.RemoveByValue(AvailableVoteMaps, string.lower(game.GetMap())) end
--Choose top x maps
for i=1,maps and #maps or SHOUT.Settings.MapsInVote,1 do
	local map = table.Random(AvailableVoteMaps)
	if SHOUT.Settings.EnableNominate and SHOUT.NominatedMaps[i] and not maps then map = SHOUT.NominatedMaps[i] end
	if (i == SHOUT.Settings.MapsInVote) and SHOUT.Settings.EnableExtendMapOption and not maps then map = string.lower(game.GetMap()) end
	table.RemoveByValue(AvailableVoteMaps, map) 
	table.insert(SHOUT.CurrentMaps, map)
end
hook.Add("Think","ShoutVote_Think",SHOUT.Think)
if #SHOUT.CurrentMaps < 1 then ErrorNoHalt("SHOUT VOTE Error: No maps could be found. Check map selection settings.") return end
net.Start("ShoutVote_New")
	net.WriteTable(SHOUT.CurrentMaps)
net.Broadcast()

//Voice loopback was disabled, here's a workaround
if not SHOUT.Settings.DisableShoutPower then
	local onlineplayers = player.GetAll()
	for k,v in pairs(onlineplayers) do
		if ((k + 1) > #onlineplayers) then
			v:SetNWEntity("ShoutPlayer",onlineplayers[1])
		else
			v:SetNWEntity("ShoutPlayer",onlineplayers[k + 1])
		end
	end
	hook.Add("PlayerCanHearPlayersVoice","ShoutVote_PlayerCanHearPlayersVoice", function(listener,talker)
		return true	
	end)
	hook.Add("PlayerDisconnected","ShoutVote_PlayerDisconnected",SHOUT.PlayerDisconnected)
end

timer.Create("ShoutVote",SHOUT.Settings.VoteTime,1,SHOUT.EndVote)

if SHOUT.Settings.FreezePlayersDuringVoting then
	for k,v in pairs(player.GetAll()) do v:Freeze(true) end
end

end
//concommand.Add("votingserver", SHOUT.StartNewVote)

function SHOUT.EndVote(cancel)
	if timer.Exists("ShoutVote") then timer.Destroy("ShoutVote") end
	
	--Database actions
	if SHOUT.CurrentMaps and not cancel then
		SHOUT.Database.SaveCurrentMap()
		SHOUT.Database.UpdateLastPlayedRounds()
		
		--Decide winner
		local winners = {}
		local highest
		
		for k,v in pairs(SHOUT.CurrentResults) do
			if not highest then highest = v table.insert(winners,k) continue end
			if (v > highest) then highest = v winners = {} table.insert(winners,k)
			elseif (v == highest) then table.insert(winners,k) end
		end
		
		--Pick random winner from table (when result is tied)
		local winningmap = table.Random(winners)
		
		net.Start("ShoutVote_End")
			net.WriteInt(winningmap or 0, 8)
			net.WriteTable(winners)
		net.Broadcast()
		
		local mapname = winningmap and SHOUT.CurrentMaps[winningmap] or game.GetMap()
		timer.Simple(SHOUT.Settings.IntermissionTime or 1, function()
			if SHOUT.Settings.FreezePlayersDuringVoting then
				for k,v in pairs(player.GetAll()) do v:Freeze(false) end
			end
			if SHOUT.Settings.EnableExtendMapOption and (mapname == string.lower(game.GetMap()) ) then
				local extendhandled = hook.Call("ShoutVote_MapExtended")
				if extendhandled then ServerLog("[SHOUT VOTE] Extending map " .. mapname .. "...") return end
			end
			ServerLog("[SHOUT VOTE] Changing map to " .. mapname .. "...")
			if not SHOUT.Settings.DeveloperMode then RunConsoleCommand("changelevel",mapname) end
		end)
	end
	
	if cancel then
		if SHOUT.Settings.FreezePlayersDuringVoting then
			for k,v in pairs(player.GetAll()) do v:Freeze(false) end
		end
		//We must call the extend map hook to restart the round/game because the vote stopped it
		hook.Call("ShoutVote_MapExtended")
		net.Start("ShoutVote_End")
			net.WriteInt(0, 8)
			net.WriteTable({})
		net.Broadcast()
	end
	
	SHOUT.InProgress = false
	SHOUT.CurrentVoters = {}
	SHOUT.CurrentResults = {}
	SHOUT.VoteRocked = false
	SHOUT.RTVPlayers = {}
	SHOUT.NominatedMaps = {}
	for k,v in pairs(player.GetAll()) do 
		v.ShoutNominated = nil 
		if not SHOUT.Settings.DisableShoutPower then v:SetNWEntity("ShoutPlayer", NULL) end
	end
	
	hook.Remove("Think","ShoutVote_Think")
	hook.Remove("PlayerDisconnected","ShoutVote_PlayerDisconnected")
	hook.Remove("PlayerCanHearPlayersVoice","ShoutVote_PlayerCanHearPlayersVoice")
end

function SHOUT.NewSelection(ply, cmd, args)
	if not IsValid(ply) or not args or not SHOUT.InProgress then return end
	local selection = tonumber(args[1])
	local map = SHOUT.CurrentMaps[selection]
	if not map or SHOUT.PlayerHasSelected(ply) then return end
	table.insert(SHOUT.CurrentVoters, {ply = ply, selection = selection})
	if SHOUT.Settings.ShowAvatars then
		net.Start("ShoutVote_Player")
			net.WriteEntity(ply)
			net.WriteInt(selection, 8)
		net.Broadcast()
	end
end
concommand.Add("Shout_NewVote",SHOUT.NewSelection)

local ThinkPollUpdate = 0.5
function SHOUT.Think()
if not SHOUT.InProgress or ((SHOUT.NextThink or 0) > CurTime()) then return end
SHOUT.NextThink = CurTime() + ThinkPollUpdate

--Recalculate vote percentages
local playersonline = #player.GetAll()
if playersonline < 1 then return end
local votepct = (100 / playersonline) * 1

SHOUT.CurrentResults = {}
for k,v in pairs(SHOUT.CurrentVoters) do
	local pct = SHOUT.CurrentResults[v.selection]
	if SHOUT.Settings.DisableShoutPower and SHOUT.UserGroupPower and IsValid(v.ply) and SHOUT.UserGroupPower[v.ply:GetUserGroup()] then
		votepct = (votepct * SHOUT.UserGroupPower[v.ply:GetUserGroup()])
	end
	SHOUT.CurrentResults[v.selection] = votepct + (pct or 0)
end

--Check SHOUT multipliers
if not SHOUT.Settings.DisableShoutPower then
	local shoutpower = (votepct / SHOUT.Settings.ShoutPower)
	for k,v in pairs(SHOUT.CurrentVoters) do
		local playerpower = SHOUT.UserGroupPower and SHOUT.UserGroupPower[v.ply:GetUserGroup()] and (votepct / SHOUT.UserGroupPower[v.ply:GetUserGroup()])

		local shoutpct = (v.shoutavg or 0) * (playerpower or shoutpower)
		SHOUT.RecalculateShoutPercentages(v.selection, shoutpct)
	end
end

net.Start("ShoutVote_Update")
	net.WriteTable(SHOUT.CurrentResults)
net.Broadcast()
end

function SHOUT.PlayerDisconnected(ply)
	if not SHOUT.InProgress then return end
	
	local ReassignPlayer = ply:GetNWEntity("ShoutPlayer")
	if not ReassignPlayer or not IsValid(ReassignPlayer) then return end
	for k,v in pairs(player.GetAll()) do
		if (v:GetNWEntity("ShoutPlayer") == ply) then v:SetNWEntity("ShoutPlayer", ReassignPlayer) end
	end	
end

function SHOUT.RecalculateShoutPercentages(selection, votepct)
if not selection or not votepct then return end
local spreadshout = #SHOUT.CurrentMaps - 1
if spreadshout < 1 then return end
local minuspct = (votepct / spreadshout)

//Add shout pct to selection
SHOUT.CurrentResults[selection] = math.Clamp(votepct + (SHOUT.CurrentResults[selection] or 0),0,100)
for k,v in pairs(SHOUT.CurrentResults) do
	if (k == selection) then continue end
	SHOUT.CurrentResults[k] = math.Clamp(v - minuspct,0,100)
end
end

function SHOUT.PlayerHasSelected(ply)
if not IsValid(ply) then return end
for k,v in pairs(SHOUT.CurrentVoters) do
	if (ply == v.ply) then
		if SHOUT.Settings.PlayersCanChangeVote then table.remove(SHOUT.CurrentVoters,k) return false
		else return true end
	end
end
return false
end

function SHOUT.PlayerShoutUpdate(len, ply)
if not IsValid(ply) then return end
local ShoutPlayer = ply:GetNWEntity("ShoutPlayer")
if not ShoutPlayer or not IsValid(ShoutPlayer) then return end
local avg = math.Clamp(tonumber(net.ReadFloat()),0,1)
for k,v in pairs(SHOUT.CurrentVoters) do
	if (ShoutPlayer == v.ply) then v.shoutavg = (v.shoutavg or 0) + avg end
end
end
net.Receive("ShoutVote_Shout",SHOUT.PlayerShoutUpdate)

function SHOUT.PlayerRTV(ply)
	if SHOUT.InProgress then return end
	if not IsValid(ply) or not SHOUT.Settings.EnableRTV then return end
	local timeremaining = (SHOUT.Settings.RTVWaitTime * 60) - CurTime()
	if timeremaining > 0 then ply:ChatPrint(string.format("You need to wait another %i minutes to rock the vote.",(timeremaining / 60))) return end
	if table.HasValue(SHOUT.RTVPlayers, ply) then ply:ChatPrint("You have already rocked the vote!") return end
	if SHOUT.VoteRocked then ply:ChatPrint("The vote has already been rocked! (Map vote will start after this round)") return end
	table.insert(SHOUT.RTVPlayers, ply)
	local votepct = (100 / #player.GetAll()) * 1
	
	//Remove invalid players from RTV
	for k,v in pairs(SHOUT.RTVPlayers) do
		if not IsValid(v) then table.remove(SHOUT.RTVPlayers,k) end
	end
	if ((votepct * #SHOUT.RTVPlayers) >= SHOUT.Settings.RTVPercent) then
		//Rock the vote
		SHOUT.VoteRocked = true

		local rtvhandled = hook.Call("ShoutVote_VoteRocked")

		if not rtvhandled then SHOUT.StartNewVote() return end
	end
	net.Start("ShoutVote_RTV")
		net.WriteTable(SHOUT.RTVPlayers)
		net.WriteEntity(ply)
	net.Broadcast()
end

function SHOUT.PlayerRTVInitialSpawn(ply)
	if not IsValid(ply) then return end
	if #SHOUT.RTVPlayers < 1 then return end
	timer.Simple(3, function()
	net.Start("ShoutVote_RTV")
		net.WriteTable(SHOUT.RTVPlayers)
	net.Send(ply)
	end)
end

if SHOUT.Settings.EnableRTV then
hook.Add("PlayerInitialSpawn","ShoutVote_RTVInitialSpawn",SHOUT.PlayerRTVInitialSpawn)
end

function SHOUT.PlayerNominate(ply, map)
	if SHOUT.InProgress then return end
	if not SHOUT.AvailableNominateMaps then SHOUT.AvailableNominateMaps = SHOUT.FindAvailableMaps() end
	if not IsValid(ply) or not SHOUT.Settings.EnableNominate or not SHOUT.AvailableNominateMaps then return end
	if (map == "") then
		net.Start("ShoutVote_NominateList")
			net.WriteTable(SHOUT.AvailableNominateMaps or {})
		net.Send(ply)
		return
	end
	
	if #SHOUT.NominatedMaps >= math.Clamp(SHOUT.Settings.MaximumNominatedMaps,0,SHOUT.Settings.MapsInVote) then ply:ChatPrint("All nominate slots have already been taken!") return end
	if ply.ShoutNominated then ply:ChatPrint("You have already nominated a map!") return end
	if not table.HasValue(SHOUT.AvailableNominateMaps,map) then ply:ChatPrint(string.format("%s can't be nominated. Say %s to choose from a menu of maps.",map,SHOUT.Settings.NominateChatCommands[1])) return end
	if table.HasValue(SHOUT.NominatedMaps,map) then ply:ChatPrint(string.format("%s has already been nominated!",map)) return end
	table.insert(SHOUT.NominatedMaps,map)
	ply.ShoutNominated = true
	net.Start("ShoutVote_Nominate")
		net.WriteEntity(ply)
		net.WriteString(map)
	net.Broadcast()
end

function SHOUT.RTVPlayerSay( ply, chattext, public )
	for k,v in pairs(SHOUT.Settings.RTVChatCommands) do
		if (string.sub(string.lower(chattext), 1, #chattext) == string.lower(v)) then
			SHOUT.PlayerRTV(ply)
			return ""
		end
	end
	if SHOUT.Settings.EnableNominate and SHOUT.Settings.NominateChatCommands and #SHOUT.Settings.NominateChatCommands > 1 then
	for k,v in pairs(SHOUT.Settings.NominateChatCommands) do
		if (string.sub(string.lower(chattext), 1, #v) == string.lower(v)) then
			SHOUT.PlayerNominate(ply, string.lower(string.Trim(string.sub( chattext, #v + 1, #chattext ))) )
			return ""
		end
	end
	end
end

function SHOUT.NominatePlayerSay( ply, chattext, public )
	for k,v in pairs(SHOUT.Settings.NominateChatCommands) do
		if (string.sub(string.lower(chattext), 1, #v) == string.lower(v)) then
			SHOUT.PlayerNominate(ply, string.lower(string.Trim(string.sub( chattext, #v + 1, #chattext ))) )
			return ""
		end
	end
end

if SHOUT.Settings.EnableRTV and SHOUT.Settings.RTVChatCommands and (#SHOUT.Settings.RTVChatCommands > 0) then
	hook.Add( "PlayerSay", "ShoutVote_RTVPlayerSay", SHOUT.RTVPlayerSay );
end
if SHOUT.Settings.EnableNominate and SHOUT.Settings.NominateChatCommands and (#SHOUT.Settings.NominateChatCommands > 0) then
	hook.Add( "PlayerSay", "ShoutVote_NominatePlayerSay", SHOUT.NominatePlayerSay );
end

function SHOUT.InitGamemodeScript()
	if file.Exists(string.format("gamemodes/%s.lua",gmod.GetGamemode().FolderName),"LUA") then
		include(string.format("gamemodes/%s.lua",gmod.GetGamemode().FolderName))
	elseif gmod.GetGamemode().BaseClass and file.Exists(string.format("gamemodes/%s.lua",gmod.GetGamemode().BaseClass.FolderName),"LUA") then
		include(string.format("gamemodes/%s.lua",gmod.GetGamemode().BaseClass.FolderName))
	else ServerLog("[SHOUT VOTE] Warning: No gamemode script found. Developers must call map vote functions manually.") end
	if SHOUT.Settings.ULXIntegration and ulx then include("sh_shoutvoteulx.lua") end
end
hook.Add("InitPostEntity","ShoutVote_Init",SHOUT.InitGamemodeScript)

function SHOUT.StopVote(ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	if not SHOUT.InProgress then
		ply:ChatPrint( "There's nothing to stop!" )
		return
	end
	for k,v in pairs(player.GetAll()) do v:ChatPrint(string.format("%s cancelled the shout vote.",ply:Nick())) end
	SHOUT.EndVote(true)
end
concommand.Add("Shout_Stop",SHOUT.StopVote)