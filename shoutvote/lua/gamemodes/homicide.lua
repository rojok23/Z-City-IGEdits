local AutoPrefixes = {	
""
}
--Override the ChangeMap to inject ShoutVote code into Homicide
 -- Change GetConVarNumber("hmcd_roundlimit") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("hmcd_roundlimit")
if ExtendByRoundsNum < 1 then RunConsoleCommand("hmcd_roundlimit",10) ExtendByRoundsNum = 3 end
 
local function OverrideChangeMap()
	SHOUT.StartNewVote()
end
gmod.GetGamemode().ChangeMap = OverrideChangeMap

local function HandleMapExtension()
	--Reset round count
	gmod.GetGamemode().RoundCount = 0
	RunConsoleCommand("hmcd_roundlimit",ExtendByRoundsNum)
	gmod.GetGamemode():SetRound(2)
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Homicide_HandleMapExtension",HandleMapExtension)

local function HandleRTV()
	gmod.GetGamemode().RoundCount = GetConVarNumber("hmcd_roundlimit") //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_Homicide_VoteRocked",HandleRTV)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end