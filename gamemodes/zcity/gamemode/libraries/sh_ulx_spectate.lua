if not ulx then return end

local CATEGORY_NAME = "ZCity Spectate"

local function beginSpectate(calling_ply, target_ply)
    calling_ply:SetTeam(TEAM_SPECTATOR)
    calling_ply.chosenSpectEntity = target_ply
    calling_ply.chosenspect = 1
    calling_ply.viewmode = 1
    calling_ply.lastSpectTarget = nil

    calling_ply:SetNWEntity("spect", target_ply)
    calling_ply:SetNWInt("viewmode", calling_ply.viewmode)

    net.Start("ZB_SpectatePlayer")
    net.WriteEntity(target_ply)
    net.WriteEntity(NULL)
    net.WriteInt(calling_ply.viewmode, 4)
    net.Send(calling_ply)

    calling_ply:Spectate(OBS_MODE_CHASE)
    calling_ply:SpectateEntity(target_ply)
end

function ulx.forcespectate(calling_ply, target_ply)
    if not IsValid(target_ply) then
        ULib.tsayError(calling_ply, "You must specify a valid player to spectate.", true)
        return
    end

    if calling_ply == target_ply then
        ULib.tsayError(calling_ply, "You cannot spectate yourself.", true)
        return
    end

    if not target_ply:Alive() then
        ULib.tsayError(calling_ply, "You can only spectate living players.", true)
        return
    end

    if calling_ply:Alive() then
        calling_ply:Kill()
    end

    beginSpectate(calling_ply, target_ply)

    ulx.fancyLogAdmin(calling_ply, "#A is now force-spectating #T", target_ply)
end

function ulx.unforcespectate(calling_ply)
    calling_ply:UnSpectate()
    calling_ply:SetObserverMode(OBS_MODE_NONE)
    calling_ply.chosenSpectEntity = nil
    calling_ply.lastSpectTarget = nil

    if calling_ply:Team() == TEAM_SPECTATOR then
        calling_ply:SetTeam(1)
    end

    if not calling_ply:Alive() and calling_ply:CanSpawn() then
        calling_ply:Spawn()
    end

    ulx.fancyLogAdmin(calling_ply, "#A stopped force-spectating")
end

local forcespectate = ulx.command(CATEGORY_NAME, "ulx forcespectate", ulx.forcespectate, "!forcespectate")
forcespectate:addParam{type = ULib.cmds.PlayerArg}
forcespectate:defaultAccess(ULib.ACCESS_ADMIN)
forcespectate:help("Force yourself to spectate a living player.")

local unforcespectate = ulx.command(CATEGORY_NAME, "ulx unforcespectate", ulx.unforcespectate, "!unforcespectate")
unforcespectate:defaultAccess(ULib.ACCESS_ADMIN)
unforcespectate:help("Stop force spectating and return to playing.")
