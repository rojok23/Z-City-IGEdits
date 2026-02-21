local AutoPrefixes = {	
	"clue",
	"cs_italy",
	"ttt_clue",
	"cs_office",
	"de_chateau",
	"de_tides",
	"de_prodigy",
	"mu_nightmare_church_b1",
	"dm_lockdown",
	"housewithgardenv2",
	"de_forest"
}
--Override the ChangeMap to inject ShoutVote code into Murder
 -- Change GetConVarNumber("mu_roundlimit") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("mu_roundlimit")
if ExtendByRoundsNum < 1 then RunConsoleCommand("mu_roundlimit",3) ExtendByRoundsNum = 3 end
 
local function OverrideChangeMap()
	SHOUT.StartNewVote()
end
gmod.GetGamemode().ChangeMap = OverrideChangeMap

local function HandleMapExtension()
	--Reset round count
	gmod.GetGamemode().RoundCount = 0
	RunConsoleCommand("mu_roundlimit",ExtendByRoundsNum)
	gmod.GetGamemode():SetRound(2)
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Murder_HandleMapExtension",HandleMapExtension)

local function HandleRTV()
	gmod.GetGamemode().RoundCount = GetConVarNumber("mu_roundlimit") //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_Murder_VoteRocked",HandleRTV)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end