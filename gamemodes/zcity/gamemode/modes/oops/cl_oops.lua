
local MODE = MODE

local OOPS = true

// net.Read("HMCD_RoundStart",function()

	// if(lply.isTraitor)then
	// 	if(MODE.TraitorExpectedAmt >= 1)then
	// 		chat.AddText("You are alone on your mission.")
	// 	end
	// end
// end)


// function MODE:HUDPaint(mode)
	// if mode == "soe3" then
// end

hook.Add("PlayerButtonDown", "TraitorPanelToggle", function(ply, btn)
    if ply ~= LocalPlayer() or btn ~= KEY_F4 then return end
    if LocalPlayer().isTraitor then return end 
    traitor_panel.visible = false
end)

