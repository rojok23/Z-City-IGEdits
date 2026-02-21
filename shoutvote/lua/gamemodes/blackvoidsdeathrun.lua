--This file is for BlackVoid's deathrun gamemode https://github.com/BlackVoid/deathrun
--It must replace the default deathrun gamemode file in shoutvote/lua/gamemodes/
local AutoPrefixes = {"dr_","deathrun_"}
--Override the MapVoteCheck function to inject ShoutVote code into BlackVoid's Deathrun
 -- Change GetConVarNumber("dr_round_limit") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("dr_round_limit")
local function MapVoteCheckOverride(self,round)
	if round >= ExtendByRoundsNum+1 then
		SHOUT.StartNewVote()
	end
end
gmod.GetGamemode().MapVoteCheck = MapVoteCheckOverride

local function HandleRTV()
	gmod.GetGamemode().Round = ExtendByRoundsNum //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_BVDeathrun_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Set to round preparing and reset rounds left global int
	RunConsoleCommand("dr_round_limit",ExtendByRoundsNum)
	gmod.GetGamemode():SetRound( 0 )
	gamemode.Call( "OnPreRoundStart", 0 ) 
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_BVDeathrun_HandleMapExtension",HandleMapExtension)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end