local AutoPrefixes = {"ttt_","cs_","de_"}
--Override the CheckForMapSwitch to inject ShoutVote code into TTT
 -- Change GetConVarNumber("ttt_round_limit") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("ttt_round_limit")
 -- Change GetConVarNumber("ttt_time_limit_minutes") to a number to override time limit amount (in minutes)
local ExtendByTimeMinutes = GetConVarNumber("ttt_time_limit_minutes")
 
function CheckForMapSwitch()
    -- Check for mapswitch
    local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
   
    SetGlobalInt("ttt_rounds_left", rounds_left)
    local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
   
	if rounds_left <= 0 or time_left <= 0 then
		timer.Stop("end2prep")
		LANG.Msg("limit_vote")
		SHOUT.StartNewVote()
	end
end

local function HandleMapExtension()
	--Restart end2prep timer
	SetGlobalInt("ttt_rounds_left", ExtendByRoundsNum)
	SetGlobalInt("ttt_time_limit_minutes", (CurTime() / 60) + ExtendByTimeMinutes)
	RunConsoleCommand("ttt_time_limit_minutes", (CurTime() / 60) + ExtendByTimeMinutes)
	timer.Create("end2prep", 1, 1, PrepareRound)
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_TTT_HandleMapExtension",HandleMapExtension)

local function HandleRTV()
	SetGlobalInt("ttt_rounds_left", 0) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_TTT_VoteRocked",HandleRTV)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end