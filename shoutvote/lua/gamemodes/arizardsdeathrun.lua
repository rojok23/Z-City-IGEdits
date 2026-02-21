--This file is for Arizards's deathrun gamemode https://github.com/Arizard/deathrun
--It must replace the default deathrun gamemode file in shoutvote/lua/gamemodes/
local AutoPrefixes = {"dr_","deathrun_"}
--Override the DeathrunShouldMapSwitch hook to turn off the built-in MapVote
 -- Change GetConVarNumber("deathrun_round_limit") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("deathrun_round_limit")

local function DeathrunShouldMapSwitch()
	SHOUT.StartNewVote()
	return "shoutvote"
end
hook.Add("DeathrunShouldMapSwitch","ShoutVote_ArizardShouldMapSwitch",DeathrunShouldMapSwitch)

local function HandleRTV()
	RunConsoleCommand("deathrun_round_limit",ROUND:GetRoundsPlayed()) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_ArizardVoteRocked",HandleRTV)
//Remove built in RTV and vote commands/hooks so Shout Vote can override them
concommand.Remove("mapvote_list_maps")
concommand.Remove("mapvote_begin_mapvote")
concommand.Remove("mapvote_nominate_map")
concommand.Remove("mapvote_update_mapvote")
concommand.Remove("mapvote_rtv")
hook.Remove("PlayerSay","CheckRTVChat")

local function HandleMapExtension()
	--Set to round preparing and reset deathrun_round_limit
	RunConsoleCommand("deathrun_round_limit",ROUND:GetRoundsPlayed() + ExtendByRoundsNum)
	ROUND:SetTimer(GetConVarNumber("deathrun_finishtime_duration") )
	timer.Simple(GetConVarNumber("deathrun_finishtime_duration") , function() 
		ROUND:RoundSwitch( ROUND_PREP ) 
	end) 
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_ArizardHandleMapExtension",HandleMapExtension)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end