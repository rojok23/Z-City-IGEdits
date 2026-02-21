if gmod.GetGamemode().Author == "BlackVoid" then include('gamemodes/blackvoidsdeathrun.lua') return
elseif gmod.GetGamemode().Author == "Arizard" then include('gamemodes/arizardsdeathrun.lua') return end
local AutoPrefixes = {"dr_","deathrun_"}
--Override the RoundEnding and RTV.Start functions to inject ShoutVote code into Deathrun
 -- Change GetConVarNumber("dr_total_rounds") to a number to override round extension amount
local ExtendByRoundsNum = GetConVarNumber("dr_total_rounds")
local DisableBuiltInRTV = true

local RTVoted
local function RoundEndingOverride(gm,winner)
	gm:SetRoundTime( 15 )

	gm:NotifyAll( winner == 123 and "Time is up!" or team.GetName(winner).."s have won!" )

	local rounds = math.max(GetGlobalInt( "dr_rounds_left", 1 ) - 1, 0)
	SetGlobalInt( "dr_rounds_left", rounds )
	
	if rounds <= 1 and not RTVoted then
		SetGlobalBool( "In_Voting", true )
		SHOUT.StartNewVote()
		RTVoted = true
	end
end
gmod.GetGamemode().RoundFunctions[ROUND_ENDING] = RoundEndingOverride

function RTV.Start()
	if RTVoted then return end
	SetGlobalBool( "In_Voting", true )
	SHOUT.StartNewVote()
	RTVoted = true
end

local function HandleRTV()
	SetGlobalInt("dr_rounds_left", 0) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_Deathrun_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Set to round preparing and reset rounds left global int
	SetGlobalInt("dr_rounds_left", ExtendByRoundsNum)
	SetGlobalBool( "In_Voting", false )
	RTVoted = false
	gmod.GetGamemode():SetRound( ROUND_PREPARING )
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Deathrun_HandleMapExtension",HandleMapExtension)

if DisableBuiltInRTV then hook.Remove("PlayerSay","RTV Chat Commands") end

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end