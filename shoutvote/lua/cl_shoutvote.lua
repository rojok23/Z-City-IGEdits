--Shout Vote Main Client Dist
if SHOUT then SHOUT = SHOUT
else SHOUT = {} end
SHOUT.CurrentHeight = 50
SHOUT.SelectionsLocked = false
SHOUT.LastRTVPercentage = 0
SHOUT.RTVPlayers = {}
include('cl_shoutfonts.lua')
include('sh_shoutconfig.lua')
--Include panels
include('panels/cl_voterow.lua')
include('panels/cl_votecountdown.lua')
include('panels/cl_rtvribbon.lua')

function SHOUT.OpenVoteScreen( settings )
	if not LocalPlayer() then return end
	SHOUT.MainWindowOpen = true
	if !VotingMainWindow then
		VotingMainWindow = vgui.Create( "DFrame" )
		VotingMainWindow:SetSize( ScrW(), ScrH() )
		VotingMainWindow:SetDraggable( false )
		if not SHOUT.Settings.ShowCloseButton and not SHOUT.Settings.DeveloperMode and not settings.nominate then VotingMainWindow:ShowCloseButton( false ) end
		VotingMainWindow:SetTitle( "" )
		VotingMainWindow:SetBackgroundBlur( true )
		VotingMainWindow.Paint = SHOUT.PaintMainWindow
		function VotingMainWindow:Close()
		    SHOUT.CloseVoteScreen()
		end
		SHOUT.VotePanels = {}
		
		VotingMainWindow.VotePanelTitle = vgui.Create("DLabel",VotingMainWindow)
		VotingMainWindow.VotePanelTitle:SetPos(ScrW() / 2, 65)
		VotingMainWindow.VotePanelTitle:SetFont("OpenSans70Font")
		SHOUT.UpdateTitleText(settings.nominate and SHOUT.Settings.NominateText or SHOUT.Settings.MakeSelectionText)
		
		//Voting panels list
		local VotingPanelsList = vgui.Create( "DPanelList", VotingMainWindow )
		VotingPanelsList:SetPadding( 0 )
		VotingPanelsList:SetSpacing( 5 )
		VotingPanelsList:SetAutoSize( false )
		VotingPanelsList:SetNoSizing( false )
		VotingPanelsList:EnableVerticalScrollbar( true )
		VotingPanelsList.Paint = function() end
		VotingPanelsList:SetSize(ScrW() - 120, ScrH() - 205)
		VotingPanelsList:SetPos(60, 150)
		
		for k,v in pairs(settings.maps) do
			local MapRow = vgui.Create("VoteRowPanel",VotingPanelsList)
			
			if #settings.maps > 5 then MapRow:SetSmallRow(true) end
			MapRow:SetMap(v, settings.nominate)
			MapRow:SetColor(SHOUT.NewVotingPanelColor())
			VotingPanelsList:AddItem(MapRow)
			//MapRow.VotePercentage = math.random(1,100)
			MapRow.DoClick = function()
				if settings.nominate then 
					LocalPlayer():ConCommand(string.format("say %s %s",SHOUT.Settings.NominateChatCommands[1],v)) 
					MapRow:ToggleSelect(true)
					if SHOUT.Settings.EnableSounds then SHOUT.PlaySound(SHOUT.Settings.MapSelectionSound) end
					timer.Simple(0.75,function()SHOUT.CloseVoteScreen() end)
					return 
				end
				if SHOUT.SelectionsLocked and SHOUT.Settings.PlayersCanChangeVote and not SHOUT.VoteChangeLocked then
					for k,v in pairs(SHOUT.VotePanels) do v:ToggleSelect(false) end
				elseif SHOUT.SelectionsLocked then return end
				SHOUT.SelectionsLocked = true
				MapRow:ToggleSelect(true)
				SHOUT.UpdateTitleText(SHOUT.Settings.DisableShoutPower and SHOUT.Settings.WaitForVictoryText or SHOUT.Settings.ShoutForVictoryText)
				RunConsoleCommand("Shout_NewVote",k)
				
				if SHOUT.Settings.EnableSounds then SHOUT.PlaySound(SHOUT.Settings.MapSelectionSound) end
			end
			table.insert(SHOUT.VotePanels, MapRow)
		end
		
		--Vote countdown panel
		if not settings.nominate then
			VotingMainWindow.VoteCountdown = vgui.Create("VoteCountdownPanel",VotingMainWindow)
			VotingMainWindow.VoteCountdown:SetPos(ScrW() / 2 - (VotingMainWindow.VoteCountdown:GetWide() / 2), ScrH() - 150 )
			VotingMainWindow.VoteCountdown:StartTimer(settings.votetime)
		else VotingMainWindow.NominateScreen = true end
		
		//timer.Simple(0.1, function() if CLSCORE and IsValid(CLSCORE.Panel) then CLSCORE.Panel:SetVisible(false) end end)
		
		VotingMainWindow:MakePopup()
		VotingMainWindow:SetKeyboardInputEnabled( false )
		VotingMainWindow:SetMouseInputEnabled( true )
		
		if IsValid(g_VoicePanelList) then g_VoicePanelList:SetParent(VotingMainWindow) end

	elseif VotingMainWindow and VotingMainWindow.NominateScreen then
		SHOUT.CloseVoteScreen()
		SHOUT.OpenVoteScreen( settings )
	else
		SHOUT.CloseVoteScreen()
	end
end
//usermessage.Hook("VOTING_Open", SHOUT.OpenVoteScreen)

function SHOUT.UpdateTitleText(text)
	if VotingMainWindow then
		VotingMainWindow.VPTHeight = 40
		VotingMainWindow.VotePanelTitle:SetText(text)
		VotingMainWindow.VotePanelTitle:SizeToContents()
		//VotingMainWindow.VotePanelTitle:SetPos(ScrW() / 2 - (VotingMainWindow.VotePanelTitle:GetWide() / 2), 65)
		VotingMainWindow.VotePanelTitle.Think = function()
			VotingMainWindow.VPTHeight = math.Approach(VotingMainWindow.VPTHeight, 65, FrameTime() * 35)
			VotingMainWindow.VotePanelTitle:SetPos(ScrW() / 2 - (VotingMainWindow.VotePanelTitle:GetWide() / 2), VotingMainWindow.VPTHeight)
		end
	end
end

local FKeyReleased = false

function SHOUT.PaintMainWindow()	
	//Paint window itself
	Derma_DrawBackgroundBlur(VotingMainWindow)
	surface.SetDrawColor(SHOUT.Theme.WindowColor)
	
	//SHOUT.CurrentHeight = math.Approach( SHOUT.CurrentHeight, SHOUT.MaxHeight, FrameTime() * 400 )
	surface.DrawRect(50, 50, ScrW() - 100, ScrH() - 100)
	
end

function SHOUT.CloseVoteScreen()
	if VotingMainWindow then
		if IsValid(g_VoicePanelList) then g_VoicePanelList:ParentToHUD(VotingMainWindow) end
		VotingMainWindow:Remove()
		VotingMainWindow = nil
		SHOUT.CanCloseTime = nil
		SHOUT.SelectionsLocked = false
		SHOUT.VotePanels = nil
		SHOUT.LastPanelNumber = nil
		FKeyReleased = false
	end
	SHOUT.MainWindowOpen = false
end

function SHOUT.NewVotingPanelColor()
	if not SHOUT.LastPanelNumber then SHOUT.LastPanelNumber = 1 
	else SHOUT.LastPanelNumber = (SHOUT.LastPanelNumber + 1) end
	
	if SHOUT.Theme.VotingStaticColors[SHOUT.LastPanelNumber] then
	return SHOUT.Theme.VotingStaticColors[SHOUT.LastPanelNumber]
	else
		local part = math.random(1,3)
		if part == 1 then return Color(255,math.random(1,255),math.random(1,255) )
		elseif part == 2 then return Color(math.random(1,255),255,math.random(1,255) )
		else return Color(math.random(1,255),math.random(1,255),255 ) end
	end
end

function SHOUT.StartNewVote()
	local settings = {}
	settings.votetime = SHOUT.Settings.VoteTime
	settings.maps = net.ReadTable()

	//RunConsoleCommand("voice_loopback",1)
	
	if SHOUT.Settings.AutoActivateMic then RunConsoleCommand("+voicerecord") end
	if not istable(settings.maps) then ErrorNoHalt("SHOUT VOTE Error: Maps table is invalid.") return end
	
	hook.Add("Think","ShoutVote_Think",SHOUT.Think)
	if SHOUT.Settings.PlayersCanChangeVote then SHOUT.VoteChangeLocked = false end
	SHOUT.OpenVoteScreen( settings )
	
	SHOUT.PlaySound(table.Random(SHOUT.Settings.VoteMusic),SHOUT.Settings.VoteMusicVolume)
	
end
net.Receive("ShoutVote_New",SHOUT.StartNewVote)

function SHOUT.UpdateVote(len)
	local update = net.ReadTable()
	if not istable(update) then ErrorNoHalt("SHOUT VOTE Error: Vote update table is invalid.") return end
	if not SHOUT.VotePanels then return end
	for k,v in pairs(update) do
		SHOUT.VotePanels[k]:SetPercentage(tonumber(v))
	end
end
net.Receive("ShoutVote_Update",SHOUT.UpdateVote)

function SHOUT.UpdatePlayerVote()
	local ply = net.ReadEntity()
	local selection = net.ReadInt(8)
	if not SHOUT.VotePanels then return end
	
	if SHOUT.Settings.PlayersCanChangeVote then
		for k,v in pairs(SHOUT.VotePanels) do
			v:RemovePlayerVote(ply)
		end
	end
	
	SHOUT.VotePanels[selection]:AddPlayerVote(ply)
end
net.Receive("ShoutVote_Player",SHOUT.UpdatePlayerVote)

local ThinkServerUpdate = 0.5
function SHOUT.Think()
	if SHOUT.Settings.DisableShoutPower then return end
	
	//Voice loopback was disabled, here's a workaround
	local ShoutPlayer = LocalPlayer():GetNWEntity("ShoutPlayer")
	if not ShoutPlayer or not IsValid(ShoutPlayer) then return end

	SHOUT.VoiceVolumeTotal = ((SHOUT.VoiceVolumeTotal or 0) + ShoutPlayer:VoiceVolume())
	SHOUT.VoiceVolumeSamples = ((SHOUT.VoiceVolumeSamples or 0) + 1)
	if not SHOUT.NextThink then SHOUT.NextThink = CurTime() + ThinkServerUpdate end
	if (CurTime() > SHOUT.NextThink) then
			SHOUT.NextThink = CurTime() + ThinkServerUpdate
			if (SHOUT.VoiceVolumeTotal < 1) or (SHOUT.VoiceVolumeSamples < 1) then return end 
			local average = (SHOUT.VoiceVolumeTotal / SHOUT.VoiceVolumeSamples)
			SHOUT.VoiceVolumeSamples = 0
			SHOUT.VoiceVolumeTotal = 0
			
			if average > 0 then
				net.Start("ShoutVote_Shout")
					net.WriteFloat(average)
				net.SendToServer()
			end
	end
end

function SHOUT.EndVote()
	local winningmap = net.ReadInt(8)
	local winners = net.ReadTable()

	if SHOUT.VotePanels then
		SHOUT.SelectionsLocked = true
		VotingMainWindow.VoteCountdown:StartTimer(SHOUT.Settings.IntermissionTime, "Changing Map:")
		if (winningmap == 0) and SHOUT.Settings.EnableExtendMapOption then
			SHOUT.UpdateTitleText(string.format("%s",SHOUT.Settings.ExtendedMapText))
			//SHOUT.VotePanels[winningmap]:SetWinner(true)
			timer.Simple(SHOUT.Settings.IntermissionTime or 1, function()
				SHOUT.CloseVoteScreen()
			end)
		elseif istable(winners) and #winners > 1 then
			SHOUT.UpdateTitleText(string.format("%s",SHOUT.Settings.ResultTiedText))
			VotingMainWindow.NextRandomThink = CurTime()
			VotingMainWindow.FlashWinningPanel = 1
			VotingMainWindow.Think = function()
				if (CurTime() < VotingMainWindow.NextRandomThink) or VotingMainWindow.RandomSelectionEnded then return end
				VotingMainWindow.NextRandomThink = CurTime() + 0.5
				if VotingMainWindow.FlashWinningPanel > #winners then VotingMainWindow.FlashWinningPanel = 1 end
				SHOUT.VotePanels[winners[VotingMainWindow.FlashWinningPanel]]:StartSelectionFlash(0.5)	
				VotingMainWindow.FlashWinningPanel = (VotingMainWindow.FlashWinningPanel + 1)
				SHOUT.PlaySound(SHOUT.Settings.RandomFlashSound)
			end
			timer.Simple(5, function()
				 if !VotingMainWindow then return end
				 VotingMainWindow.RandomSelectionEnded = true
				 SHOUT.VotePanels[winningmap]:SetWinner(true)
			end)
			if SHOUT.Settings.EnableExtendMapOption and (string.lower(SHOUT.VotePanels[winningmap]:GetMap()) == string.lower(game.GetMap())) then
				timer.Simple(SHOUT.Settings.IntermissionTime or 1, function()
					SHOUT.CloseVoteScreen()
				end)
			end
		elseif (winningmap > 0) and SHOUT.Settings.EnableExtendMapOption and (string.lower(SHOUT.VotePanels[winningmap]:GetMap()) == string.lower(game.GetMap())) then
			SHOUT.UpdateTitleText(string.format("%s",SHOUT.Settings.ExtendedMapText))
			SHOUT.VotePanels[winningmap]:SetWinner(true)
			timer.Simple(SHOUT.Settings.IntermissionTime or 1, function()
				SHOUT.CloseVoteScreen()
			end)
		elseif (winningmap > 0) then
			SHOUT.UpdateTitleText(string.format("%s %s",SHOUT.Settings.WinningMapText,SHOUT.VotePanels[winningmap]:GetMap()))
			SHOUT.VotePanels[winningmap]:SetWinner(true)
		else SHOUT.CloseVoteScreen() end
		
		if SHOUT.Settings.EnableSounds then SHOUT.PlaySound(SHOUT.Settings.VoteResultsSound) end
	end

	//RunConsoleCommand("voice_loopback",0)
	if SHOUT.Settings.AutoActivateMic then RunConsoleCommand("-voicerecord") end
	if SHOUT.Settings.PlayersCanChangeVote then SHOUT.VoteChangeLocked = true end
	hook.Remove("Think","ShoutVote_Think")
	SHOUT.VoiceVolumeSamples = 0
	SHOUT.VoiceVolumeTotal = 0
	SHOUT.LastRTVPercentage = nil
	SHOUT.RTVPlayers = {}
end
net.Receive("ShoutVote_End",SHOUT.EndVote)

local function CalculateRTVPlayersAndPercentage(voters)
	local votepct = (100 / #player.GetAll()) * 1
	local currentpct = votepct * #voters
	local votesneeded = 0
	local testingpct = currentpct
	
	if currentpct < SHOUT.Settings.RTVPercent then
		for k,v in pairs(player.GetAll()) do
			testingpct = (testingpct + votepct)
			
			votesneeded = (votesneeded + 1)
			if (testingpct >= SHOUT.Settings.RTVPercent) then break end
		end
	end
	return votesneeded,currentpct
end

function SHOUT.PlayerRTV()
	local players = net.ReadTable()
	local ply = net.ReadEntity()
	if not istable(players) then return end
	SHOUT.RTVPlayers = players
	
	local votesneeded,percentage = CalculateRTVPlayersAndPercentage(SHOUT.RTVPlayers)
	if SHOUT.Settings.EnableChatNotifications and (votesneeded > 0) and IsValid(ply) and ply.Nick then
		chat.AddText(SHOUT.Theme.RTVPrefixColor, "[RTV] ", SHOUT.Theme.RTVTextColor, string.format("%s has voted to rock the vote! (Another %i votes needed.)",ply:Nick(),votesneeded) )
	elseif SHOUT.Settings.EnableChatNotifications and (votesneeded <= 0) and IsValid(ply) and ply.Nick then
		chat.AddText(SHOUT.Theme.RTVPrefixColor, "[RTV] ", SHOUT.Theme.RTVTextColor, string.format("The vote will start after this round. (%s got the final vote)",ply:Nick()) )
	end
	if SHOUT.Settings.EnableRTVRibbon and IsValid(ply) and (SHOUT.Settings.ShowRTVRibbonUpdatesToEverybody or (ply == LocalPlayer())) then
		local settings = {}
		settings.closetime = CurTime() + SHOUT.Settings.RTVRibbonUpdateShowTime
		settings.update = true
		SHOUT.ShowRTVRibbon(settings)
	end
	SHOUT.LastRTVPercentage = percentage
	if IsValid(ply) then SHOUT.PlaySound(SHOUT.Settings.RTVSound) end
end
net.Receive("ShoutVote_RTV",SHOUT.PlayerRTV)

function SHOUT.PlayerNominate()
	local ply = net.ReadEntity()
	local map = net.ReadString()
	if not IsValid(ply) or not ply.Nick then return end
	
	chat.AddText(SHOUT.Theme.RTVPrefixColor, "[RTV] ", SHOUT.Theme.RTVTextColor, string.format("%s has nominated the map: %s",ply:Nick(),map) )
end
net.Receive("ShoutVote_Nominate",SHOUT.PlayerNominate)

function SHOUT.ShowNominateList()
	local settings = {}
	settings.nominate = true
	settings.maps = net.ReadTable()
	
	SHOUT.OpenVoteScreen( settings )
end
net.Receive("ShoutVote_NominateList",SHOUT.ShowNominateList)

function SHOUT.ShowRTVRibbon(settings)
	if not settings or VotingMainWindow then return end
	if !SHOUT.RTVRibbon and !settings.forceclose then
		//Remove invalid players from RTV
		for k,v in pairs(SHOUT.RTVPlayers) do
			if not IsValid(v) then table.remove(SHOUT.RTVPlayers,k) end
		end	
		SHOUT.RTVRibbon = vgui.Create("RTVRibbon")
		SHOUT.RTVRibbon:ParentToHUD()
		local votesneeded,percentage = CalculateRTVPlayersAndPercentage(SHOUT.RTVPlayers)
		SHOUT.RTVRibbon:SetData(SHOUT.RTVPlayers, percentage, votesneeded, settings.update)
		if settings.closetime then SHOUT.RTVRibbon:SetCloseTime(settings.closetime) end
	elseif SHOUT.RTVRibbon and settings.forceclose then
		SHOUT.RTVRibbon:Remove()
		SHOUT.RTVRibbon = nil
	elseif SHOUT.RTVRibbon then
		//Remove invalid players from RTV
		for k,v in pairs(SHOUT.RTVPlayers) do
			if not IsValid(v) then table.remove(SHOUT.RTVPlayers,k) end
		end
		local votesneeded,percentage = CalculateRTVPlayersAndPercentage(SHOUT.RTVPlayers)
		SHOUT.RTVRibbon:SetData(SHOUT.RTVPlayers, percentage, votesneeded, settings.update)
		SHOUT.RTVRibbon:SetCloseTime(settings.closetime)
	end
end
//concommand.Add("voting_rtvribbon",SHOUT.ShowRTVRibbon)

if SHOUT.Settings.EnableRTV and SHOUT.Settings.ShowRTVRibbonOnScoreboard then
	local settings = {}
	settings.forceclose = true
	hook.Add("ScoreboardShow","ShoutVote_ScoreboardShow_RTV",function() SHOUT.ShowRTVRibbon({}) end)
	hook.Add("ScoreboardHide","ShoutVote_ScoreboardShow_RTV",function() SHOUT.ShowRTVRibbon(settings) end)
end

function SHOUT.Initialize()
	if SHOUT.Settings.ULXIntegration and ulx then include("sh_shoutvoteulx.lua") end
	
	//Create shout vote map images directory
	file.CreateDir("shoutvote")
	
	//Expire map icons after 30 days to refresh incase of icon updates
	local icons = file.Find("shoutvote/*","DATA")
	for k,v in pairs(icons) do
		if (file.Time(string.format("shoutvote/%s",v),"DATA") <= (os.time() - 2592000)) then
			file.Delete(string.format("shoutvote/%s",v))
		end
	end
end
hook.Add("InitPostEntity","ShoutVote_Init",SHOUT.Initialize)

function SHOUT.PlaySound(file,volume)
	if not file or not SHOUT.Settings.EnableSounds or not system.HasFocus() then return end
	if string.StartWith(file,"http://") or string.StartWith(file,"www.") then
		sound.PlayURL(file,"", function(audio)
			if IsValid(audio) and volume then
				audio:Play()
				audio:SetVolume(math.Clamp(volume,0,1))
			end
		end)
	else surface.PlaySound(file)
	end
end