--Shout Vote ULX Integration Server Dist
if SERVER then

function ulx.shoutvote(ply, ...)
	if not IsValid(ply) then return end
	local argv = { ... }
	if SHOUT.InProgress then
		ULib.tsayError( ply, "There is already a shout vote in progress. Please wait for the current one to end.", true )
		return
	end
	
	for i=2, #argv do
	    if ULib.findInTable( argv, argv[ i ], 1, i-1 ) then
	        ULib.tsayError( calling_ply, "Map " .. argv[ i ] .. " was listed twice. Please try again" )
	        return
	    end
	end
	if #argv > 1 then
		ulx.fancyLogAdmin( ply, "#A started a shout vote with options" .. string.rep( " #s", #argv ), ... )
		SHOUT.StartNewVote(argv)
	else
		table.insert(argv,string.lower(game.GetMap()))
		ulx.fancyLogAdmin( ply, "#A started a shout vote for #s", argv[1] )
		SHOUT.StartNewVote(argv)
	end
end

function ulx.vetoshoutvote(ply)
	if not IsValid(ply) then return end
	
	if not SHOUT.InProgress then
		ULib.tsayError( ply, "There's nothing to stop!", true )
		return
	end
	
	ulx.fancyLogAdmin( ply, "#A cancelled the shout vote." )
	SHOUT.EndVote(true)
end

end

local CATEGORY_NAME = "Voting"
-- This command can cancel any shout vote in progress
local cancel = ulx.command( CATEGORY_NAME, "ulx stopshout", ulx.vetoshoutvote, "!stopshout" )
cancel:defaultAccess( ULib.ACCESS_ADMIN )
cancel:help( "Stops a shout vote that's in progress" )

--This command starts a shoutvote, if only one map is selected, the other option will be to extend
local votemap = ulx.command( CATEGORY_NAME, "ulx shoutvote", ulx.shoutvote, "!shoutvote" )
votemap:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="map", error="invalid map \"%s\" specified", ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min=1, repeat_max=10 }
votemap:defaultAccess( ULib.ACCESS_ADMIN )
votemap:help( "Starts a shout vote between the selected maps" )

if CLIENT then
	function xgui.toggle( tabname )
		if xgui.anchor and ( not xgui.anchor:IsVisible() or ( tabname and #tabname ~= 0 ) ) then
			xgui.show( tabname )
			xgui.anchor:MakePopup()
			xgui.anchor:SetKeyboardInputEnabled( false )
			xgui.anchor:SetMouseInputEnabled( true )
		else
			xgui.hide()
		end
	end
end
