local AutoPrefixes = {"jb_","ba_"}
--Hook the JailBreakStartMapvote in Excl's jailbreak to trigger the Shout Vote

local function ShoutVoteJailBreakStartMapvote(gm,roundnum,extensionnum)
	--Start the Shout Vote map vote here
	SHOUT.StartNewVote()
	return true
end
hook.Add("JailBreakStartMapvote","ShoutVote_ExclJailBreak_StartMapvote",ShoutVoteJailBreakStartMapvote)

local function HandleRTV()
	JB.RoundsPassed = tonumber(JB.Config.roundsPerMap) //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_ExclJailbreak_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Call the extend map function
	JB:Mapvote_ExtendCurrentMap()
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_ExclJailbreak_HandleMapExtension",HandleMapExtension)

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end