local AutoPrefixes = {	
	"cs_office ",
	"cs_italy",
	"cs_compound ",
	"de_inferno",
	"de_tides",
	"gm_metro_plaza",
	"gm_arena_submerge",
	"gm_1950s_town",
	"ttt_bb_suburbia_b3",
	"rp_resort",
	"cs_meridian"
}

--Override the MapVote to inject ShoutVote code into GuessWho
 -- Change GetConVarNumber("gw_maxrounds") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("gw_maxrounds")
if ExtendByRoundsNum < 1 then RunConsoleCommand("gw_maxrounds",8) ExtendByRoundsNum = 8 end

MapVote = {}
local function OverrideChangeMap()
	SHOUT.StartNewVote()
end
MapVote.Start = OverrideChangeMap

local function HandleMapExtension()
	--Reset round count
	SetGlobalInt( "RoundNumber", 0)
	RunConsoleCommand("gw_maxrounds",ExtendByRoundsNum)
	gmod.GetGamemode():PostRound()
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Murder_HandleMapExtension",HandleMapExtension)

local function HandleRTV()
	SetGlobalInt( "RoundNumber", GetConVarNumber("gw_maxrounds")) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_GuessWho_VoteRocked",HandleRTV)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end