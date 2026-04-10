
local MODE = MODE

MODE.GuiltDisabled = true
MODE.PoliceTime = 9999

function MODE:AfterBaseInheritance()
	self.Types.standard3 = self.Types.standard
	self.Types.soe3 = self.Types.soe

	self.Types.wildwest = nil
	self.Types.gunfreezone = nil
	self.Types.standard = nil
	self.Types.soe = nil
end

function MODE:CanLaunch()
	return false
end

local modes = {
	"soe3",
	"standard3",
}

function MODE:SubModes()
	return modes
end

function MODE:Intermission()
	game.CleanUpMap()

	MODE.saved.TimePlayed = 0
	MODE.saved.KillTime = CurTime() + 60

	local _,CROUND = CurrentRound()

	if not CROUND or CROUND == "hmcd" then
		CROUND = table.Random(self:SubModes())
	end

	self.Type = CROUND
	local player_count = 0

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:KillSilent()

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil

		ply:SetupTeam(0)

		ply.organism.recoilmul = DefaultSkillIssue
		player_count = player_count + 1
	end

	MODE.TraitorFrequency = nil
	// MODE.TraitorWord = MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	// MODE.TraitorWordSecond = MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	local traitors_needed = math.min(player_count - 0)

	MODE.TraitorExpectedAmt = traitors_needed
	local main_traitor = nil
	local traitors = {}


	//MODE.NextRoundMainTraitors = MODE.NextRoundMainTraitors or {}
	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		//if not MODE.NextRoundMainTraitors[ply:SteamID()] then continue end

		if traitors_needed >= 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply

			main_traitor = ply
			ply.MainTraitor = true
			//MODE.NextRoundMainTraitors[ply:SteamID()] = nil
		end
	end


	// for i, ply in RandomPairs(player.GetAll()) do
	// 	if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
	// 	if math.random(100) > (ply.Karma or 100) then continue end

	// 	if traitors_needed > 0 then
	// 		ply.isTraitor = true
	// 		traitors_needed = traitors_needed - 1
	// 		traitors[#traitors + 1] = ply

	// 		if not main_traitor then
	// 			main_traitor = ply
	// 			ply.MainTraitor = true
	// 		end
	// 	end
	// end

	// if traitors_needed > 0 then
	// 	for i, ply in RandomPairs(player.GetAll()) do
	// 		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

	// 		if traitors_needed > 0 then
	// 			ply.isTraitor = true
	// 			traitors_needed = traitors_needed - 1
	// 			traitors[#traitors + 1] = ply

	// 			if not main_traitor then
	// 				main_traitor = ply
	// 				ply.MainTraitor = true
	// 			end
	// 		end
	// 	end
	// end

	-- self.saved.PoliceTime = CurTime() + math.min(self.Types[self.Type].PoliceTime * (#player.GetAll() / 4),self.Types[self.Type].PoliceTime * 2.2)
	self.saved.PoliceTime = 99999
	self.PoliceSpawned = false
	self.PoliceAllowed = false

	for k, ply in player.Iterator() do
		if(MODE.ShouldStartRoleRound())then
			net.Start("HMCD_RoundStart")	--; TODO Structure description
				net.WriteBool(ply.isTraitor)	--; Is Traitor
				net.WriteBool(ply.isGunner)	--; Is Gunner
				net.WriteString(self.Type)	--; Round Type
				net.WriteBool(false)	--; Round Started
				net.WriteString("")	--; SubRole
				net.WriteBool(ply.MainTraitor == false)	--; MainTraitor

				if(ply.isTraitor)then
					net.WriteString(MODE.TraitorWord)
					net.WriteString(MODE.TraitorWordSecond)
					net.WriteUInt(MODE.TraitorExpectedAmt, MODE.TraitorExpectedAmtBits)
				else
					net.WriteString("")
					net.WriteString("")
					net.WriteUInt(0, MODE.TraitorExpectedAmtBits)
				end

				net.WriteString("")	--; Profession
			net.Send(ply)

			local role = self.Roles[self.Type][(ply.isTraitor and "traitor") or (ply.isGunner and "gunner") or "innocent"]

			zb.GiveRole(ply, role.name, role.color)
		end
	end
end

function MODE:ShouldRoundEnd()
	return #zb:CheckAlive() == 1
end