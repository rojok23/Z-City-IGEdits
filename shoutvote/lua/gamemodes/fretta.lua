--Override the StartMapVote to inject ShoutVote code into Fretta gamemodes
 -- Change gmod.GetGamemode().RoundLimit to a number to override round extension amount
local ExtendByRoundsNum = gmod.GetGamemode().RoundLimit
 -- Change gmod.GetGamemode().GameLength to a number to override time limit amount (in minutes)
local ExtendByTimeMinutes = gmod.GetGamemode().GameLength

local function SetNextFrettaPrefixes(winner)
	local nextgamemode = winner or gmod.GetGamemode().FolderName
	local info = file.Read( "gamemodes/"..nextgamemode.."/"..nextgamemode..".txt", "GAME" )
	if info then
		local info = util.KeyValuesToTable( info )
		if info.fretta_maps then SHOUT.Settings.MapPrefixes = info.fretta_maps end
	end
end
if SHOUT.Settings.AutoSetPrefixes then SetNextFrettaPrefixes() end
 
local function OverrideStartMapVote()
	RunConsoleCommand( "gamemode", gmod.GetGamemode().WorkOutWinningGamemode and gmod.GetGamemode():WorkOutWinningGamemode() or engine.ActiveGamemode() )
	SetNextFrettaPrefixes(gmod.GetGamemode().WorkOutWinningGamemode and gmod.GetGamemode():WorkOutWinningGamemode() or engine.ActiveGamemode())
	SHOUT.StartNewVote()
end
gmod.GetGamemode().StartMapVote = OverrideStartMapVote
if not MapVote then MapVote = {} end
MapVote.Start = OverrideStartMapVote

local function HandleMapExtension()
	return false //We want to reload the map even if its extended in Fretta
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Fretta_HandleMapExtension",HandleMapExtension)

local function HandleRTV()
	SetGlobalInt( "RoundNumber", gmod.GetGamemode().RoundLimit) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_Fretta_VoteRocked",HandleRTV)