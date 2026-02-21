if JB and JB.Mapvote_StartMapVote then include('gamemodes/excljailbreak.lua') return end
local AutoPrefixes = {"jb_","ba_"}
--Override the CheckForVote and RTV.Start functions to inject ShoutVote code into Deathrun
 -- Change GetGlobalInt( "jb_rounds", 10 ) to a number to override round extension amount
local ExtendByRoundsNum = GetGlobalInt( "jb_rounds", 10 )
local DisableBuiltInRTV = true

local RTVoted
local function CheckForVoteOverride(gm,winner)
	local rounds = GetGlobalInt( "jb_rounds", 10 )-1
	SetGlobalInt( "jb_rounds", rounds )
	
	if rounds<=0 then
		gmod.GetGamemode().SetRoundEndTime( CurTime()+30 )
		SHOUT.StartNewVote()
	end
end
gmod.GetGamemode().CheckForVote = CheckForVoteOverride

local function RTVStartOverride()
	if RTVoted then return end
	SHOUT.StartNewVote()
	RTVoted = true
end
gmod.GetGamemode().MapVote.Start = RTVStartOverride

local function HandleRTV()
	SetGlobalInt("jb_rounds", 0) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_Jailbreak_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Trigger round start and reset round count
	SetGlobalInt( "jb_rounds", ExtendByRoundsNum )
	RTVoted = false
	gmod.GetGamemode():StartRound( )
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Jailbreak_HandleMapExtension",HandleMapExtension)

if DisableBuiltInRTV then hook.Remove("PlayerSay","JBVote RTV") end

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end