SHOUT.Theme = {}
--
-- Shout Vote Theme
--

SHOUT.Theme.WindowColor = Color(51, 51, 51, 255) --Main window color
SHOUT.Theme.ControlColor = Color( 38, 41, 49, 255) --Main window control color
SHOUT.Theme.RTVBarColor = Color(41, 128, 185) --RTV bar color
SHOUT.Theme.SelectedMat = Material("shoutvote/tick.png") --Selected map overlay
SHOUT.Theme.WinnerMat = Material("shoutvote/star1.png") --Winning map overlay
SHOUT.Theme.TimerCircleMat = Material("shoutvote/timecircle.png","noclamp") --Timer circle material
SHOUT.Theme.TimerCircleColor = Color(41, 128, 185) --Timer circle color

SHOUT.Theme.RTVPrefixColor = Color(52, 152, 219) --Chat text color of RTV prefix
SHOUT.Theme.RTVTextColor = Color(255,102,51) --Chat text color of RTV notices
SHOUT.Theme.VotingStaticColors = {Color(41, 128, 185),Color(26,83,255),Color(255,77,77),
Color(230,184,0),Color(0,179,54)} --Static vote bar colors (will always be used first)

SHOUT.Settings = {}
--
-- Shout Vote Settings
--
SHOUT.Settings.MapPrefixes = {"ttt_", "mu_", "de_forest", "gm_1590s_town", "gm_city17_apartments", "gm_city_at_night", "gm_cliffside_house", "gm_hetveer", "gm_house3v4", "gm_metro_side", "cs_office", "cs_italy", "de_prodigy", "zs_castle_keep_snowy"} --Used to select maps for the vote
SHOUT.Settings.AutoSetPrefixes = false --ShoutVote will set prefixes based on which gamemode is running
SHOUT.Settings.VoteTime = 35 -- How long should a vote last? (in seconds)
SHOUT.Settings.MapsInVote = 15 --Maximum number of map options in vote
SHOUT.Settings.IntermissionTime = 10 --Time between vote results and map change (in seconds)
SHOUT.Settings.MapRoundsCooldown = 5 --Number of rounds until map can be voted on again (0 to disable)
SHOUT.Settings.MapLastPlayedCooldown = 30 --Number of minutes until map can be vote on again (0 to disable)
SHOUT.Settings.EnableExtendMapOption = true -- Can current map be extended?
SHOUT.Settings.PlayersCanChangeVote = true --Can players change their vote after selecting a map
SHOUT.Settings.FreezePlayersDuringVoting = false --Players will not be able to move during a map vote

SHOUT.Settings.ULXIntegration = true --ULX integration for starting custom shout votes/vetoing

SHOUT.Settings.DisableShoutPower = false --No shout power, addon behaves like normal map vote
SHOUT.Settings.AutoActivateMic = false --Auto activate mic during voting
SHOUT.Settings.ShoutPower = 10 --Shout power, fraction of selection vote (lower number for more shout power)

SHOUT.Settings.ShowPercentages = true --Show % amounts on voting bar?
SHOUT.Settings.ShowAvatars = true --Show player avatars on voting bar?
SHOUT.Settings.ShowCloseButton = false --Show close button on voting screen

SHOUT.Settings.MakeSelectionText = "Make your selection" -- Tell players to pick a map
SHOUT.Settings.ShoutForVictoryText = "Now SHOUT for your map!!" --Tell players they can now shout
SHOUT.Settings.WaitForVictoryText = "Waiting for results..." --Waiting for results (shout power disabled)
SHOUT.Settings.WinningMapText = "And the winner is" -- Winning map selected
SHOUT.Settings.ExtendedMapText = "Map will be extended..." --Current map extended
SHOUT.Settings.ResultTiedText = "Result is tied! Picking a winner..." --Result is tied. Random selection
SHOUT.Settings.NominateText = "Choose a map to nominate" -- Tell players to nominate a map

SHOUT.Settings.EnableSounds = true --Play the menu sounds?
SHOUT.Settings.MapSelectionSound = "http://fastdl.friendlyplayers.com/as/mapselection.wav" --Map selected
SHOUT.Settings.VoteResultsSound = "http://fastdl.friendlyplayers.com/as/shoutvoteresult.mp3" --Vote results
SHOUT.Settings.RandomFlashSound = "common/talk.wav"
SHOUT.Settings.RTVSound = "ui/freeze_cam.wav"

--Vote music, you can specify multiple files, seperate each with a comma.
--Sounds can be local or from the web (.mp3 or .wav files)
SHOUT.Settings.VoteMusic = {"http://fastdl.friendlyplayers.com/as/shoutvote1.mp3",
"http://fastdl.friendlyplayers.com/as/shoutvote2.mp3",
"http://fastdl.friendlyplayers.com/as/shoutvote3.mp3",
"http://fastdl.friendlyplayers.com/as/shoutvote4.mp3"}
SHOUT.Settings.VoteMusicVolume = 0.5 --Volume of vote music (must be between 0 lowest and 1 highest)

SHOUT.Settings.EnableRTV = true
SHOUT.Settings.RTVChatCommands = {"!rtv","/rtv","rtv"} --RTV chat commands
SHOUT.Settings.ShowRTVRibbonOnScoreboard = true --Show the RTV bar on the scoreboard?
SHOUT.Settings.RTVWaitTime = 5 --Time before RTV can be started on a new map (in minutes)
SHOUT.Settings.RTVPercent = 66 --Percent of players needed to RTV before vote is triggered
SHOUT.Settings.EnableChatNotifications = true --Show RTV notices in chat box
SHOUT.Settings.EnableRTVRibbon = true -- Show the RTV bar?
SHOUT.Settings.RTVRibbonUpdateShowTime = 7 -- Show the RTV bar for x seconds when someone new votes
SHOUT.Settings.ShowRTVRibbonUpdatesToEverybody = true --Show the RTV bar to everyone when someone new votes

SHOUT.Settings.EnableNominate = true
SHOUT.Settings.NominateChatCommands = {"!nominate","/nominate","nominate"} --RTV nomination chat commands
SHOUT.Settings.MaximumNominatedMaps = 5 --How many map vote slots can be nominated by players
--You can add different shout power for ULX groups
-- add a new line without the // with your group name and shout power amount
-- (Lower number gives more shout power)
SHOUT.UserGroupPower = {}
//SHOUT.UserGroupPower["admin"] = 7
//SHOUT.UserGroupPower["superadmin"] = 4
//SHOUT.UserGroupPower["vipmembers"] = 5