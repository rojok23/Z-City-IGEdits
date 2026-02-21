local AutoPrefixes = {"zs_","zm_","zh_","zps_","zr_","ze_"}
--Override the LoadNextMap function to inject ShoutVote code into Zombie Survival
 -- Change GetConVarNumber("zs_roundlimit") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("zs_roundlimit")
 -- Change GetConVarNumber("zs_timelimit") to a number to override time limit amount (in minutes)
local ExtendByTimeMinutes = GetConVarNumber("zs_timelimit")

local function LoadNextMapOverride()
	SHOUT.StartNewVote()
end
gmod.GetGamemode().LoadNextMap = LoadNextMapOverride

local function HandleRTV()
	gmod.GetGamemode().RoundLimit = 1 //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_ZS_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Set to round preparing and reset rounds left global int
	gmod.GetGamemode().CurrentRound  = 0
	gmod.GetGamemode().RoundLimit = ExtendByRoundsNum
	gmod.GetGamemode().TimeLimit = CurTime() + (ExtendByTimeMinutes * 60)
	gamemode.Call("PreRestartRound")
	timer.Simple(3, function() gamemode.Call("RestartRound") end)
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_ZS_HandleMapExtension",HandleMapExtension)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end