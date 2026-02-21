local AutoPrefixes = {"bhop_"}
--To enable the global timelimit for the map, set EnableBhopTimelimit = true below and change 
-- the BhopTimeLimit to a number of minutes for the map vote to trigger without RTV.
local EnableBhopTimelimit = false
local BhopTimeLimit = 20 //Number in minutes

local function HandleRTV()
	//Map vote will trigger right away in Bhop
	BHOP.Voting = true
	return false
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_Bhop_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Map was extended, so restart the map timer if it's enabled.
	BHOP.Voting = false
	if EnableBhopTimelimit then 
		timer.Create("ShoutVote_Bhop_MapTimer",BhopTimeLimit * 60,1,function()
		BHOP.Notify( Color(129,207,224), "[SHOUT VOTE] ", color_white, " The map time limit is up! A mapvote will begin in 60 seconds." )
		timer.Simple(60, function() SHOUT.StartNewVote() BHOP.Voting = true end)
		end)
	end
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_Bhop_HandleMapExtension",HandleMapExtension)

if EnableBhopTimelimit then
	timer.Create("ShoutVote_Bhop_MapTimer",BhopTimeLimit * 60,1,function()
		BHOP.Notify( Color(129,207,224), "[SHOUT VOTE] ", color_white, " The map time limit is up! A mapvote will begin in 60 seconds." )
		timer.Simple(60, function() SHOUT.StartNewVote() BHOP.Voting = true end)
	end)
end

local DisableBuiltInRTV = true
if DisableBuiltInRTV then 
	hook.Remove("PlayerSay","Bhop.RTVCommand")
	hook.Remove("PlayerSay","Bhop.ForceMapvoteCommand")
	hook.Remove("PlayerSay","Bhop.NominateMap")
	hook.Add("PlayerSay", "Bhop.ForceMapvoteCommand", function(ply, text, pub)
	if BHOP.CanPlaceStartingAndEnding(ply) then
		if table.HasValue( {"!mapvote","/mapvote",":mapvote",".mapvote",}, string.lower(text) ) then
			BHOP.Notify( Color(129,207,224), ply:Nick(), color_white, " has forced a mapvote." )
			SHOUT.StartNewVote()
			BHOP.Voting = true
			return ""
		end
	end
end)
end

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end