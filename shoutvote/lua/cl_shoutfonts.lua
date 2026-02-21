--ShoutVote System Fonts
local function LoadShoutVoteFonts()
//if SHOUT.FontsLoaded then return end
surface.CreateFont("Bebas24Font", {font = "Bebas Neue", size= 24, weight = 400, antialias = true } )
surface.CreateFont("Bebas40Font", {font = "Bebas Neue", size= 40, weight = 400, antialias = true } )

surface.CreateFont("OpenSans70Font", {font = "Open Sans Condensed", size= 70, weight = 400, antialias = true } )
surface.CreateFont("OpenSans50Font", {font = "Open Sans Condensed", size= 50, weight = 400, antialias = true } )
surface.CreateFont("OpenSans30Font", {font = "Open Sans Condensed", size= 30, weight = 400, antialias = true } )
SHOUT.FontsLoaded = true
end
LoadShoutVoteFonts()
hook.Add("InitPostEntity", "SHOUT_InitPostLoadFonts", LoadShoutVoteFonts)