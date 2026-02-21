local AutoPrefixes = {"has_"}
--Override the RTVActivated function to inject ShoutVote code into Hide and Seek

local DisableBuiltInRTV = true

function RTVActivated(how)
	if how == "rtv" then
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[chat.AddText(Color(255,255,255),"Majority RTV'd! Starting Shout Vote...") surface.PlaySound("music/class_menu_09.wav")]])
		end
		timer.Simple(5,function() SHOUT.StartNewVote() end)
	else
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[chat.AddText(Color(255,255,255),"Starting Shout Vote...") surface.PlaySound("music/class_menu_09.wav") GameEnd = true]])
		end
		
		GameEnd = true
		local scores = {}
		for k,v in pairs(player.GetAll()) do
			scores[v:EntIndex()] = v:Frags()
		end
		local winner = Entity(table.GetWinningKey(scores))
		if winner:IsValid() then
			if (winner:Team() == 3 or winner:Team() == 4) then
				winner:SetTeam(2)
				winner:Spawn()
			end
			winner:SetPlayerColor(Vector(1,1,0))
			winner:SetColor(Color(255,200,0))
			winner:SetMaterial("models/shiny")
			winner:SendLua([[InfSta = 1]])
			winner:SetJumpPower(630)
			winner:SetWalkSpeed(350)
			winner:SetRunSpeed(550)
			winner:EmitSound("misc/tf_crowd_walla_intro.wav",80,100)
		end
		hook.Call("HASGameEnded",GAMEMODE,winner)
		timer.Simple(5,function()
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[if not ScoBIsShowing then ScoBShow() end]])
			end
		end)
		timer.Simple(15,function() SHOUT.StartNewVote() end)
	end
end

local function HandleRTV()
	RoundCount = GetConVarNumber("has_maxrounds") //Map vote will trigger at the end of this round
	return true
end
hook.Add("ShoutVote_VoteRocked","ShoutVote_HS_VoteRocked",HandleRTV)

local function HandleMapExtension()
	--Set round active to false and restart round
	RoundCount = 0
	RoundActive = false
	TimeLimit(false)
	if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
	timer.Simple(3,function() RoundRestart() end)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[RoundActive = false TimeLimit(false) chat.AddText(Color(255,255,255),"Map was extended...")]])
	end
	return true
end
hook.Add("ShoutVote_MapExtended","ShoutVote_HS_HandleMapExtension",HandleMapExtension)

if DisableBuiltInRTV then timer.Simple(3, function() RunConsoleCommand("has_rtv_enabled",0) end) end

if SHOUT.Settings.AutoSetPrefixes then timer.Simple(3, function() SHOUT.Settings.MapPrefixes = AutoPrefixes end) end