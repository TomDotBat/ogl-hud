
surface.CreateFont("OGL.HUD.VoteTitle", {
    font = "Montserrat SemiBold",
    size = 26,
    weight = 500,
})

surface.CreateFont("OGL.HUD.VoteQuestion", {
    font = "Montserrat Medium",
    size = 20,
    weight = 500,
})

surface.CreateFont("OGL.HUD.VoteButton", {
    font = "Montserrat Medium",
    size = 22,
    weight = 500,
})

surface.CreateFont("OGL.HUD.DermaTitle", {
    font = "Montserrat SemiBold",
    size = 25,
    weight = 500,
})

surface.CreateFont("OGL.HUD.Button", {
    font = "Montserrat Medium",
    size = 22,
    weight = 500,
})

local hiddenHUDElements = {
    DarkRP_HUD = true,
    DarkRP_EntityDisplay = true,
    DarkRP_ZombieInfo = true,
    DarkRP_LocalPlayerHUD = true,
    DarkRP_Hungermod = true,
    DarkRP_Agenda = true,
    CHudHealth = true,
    CHudBattery = true,
    CHudDamageIndictator = true,
    CHudZoom = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudDeathNotice = true
}

hook.Add("HUDShouldDraw", "OGLHUD.HideDefaults", function(name)
    if (hiddenHUDElements[name]) then return false end
end)

hook.Add("HUDDrawTargetID", "OGLHUD.HideTargetID", function()
    return false
end)

usermessage.Hook("_Notify", function(msg)
    local txt = msg:ReadString()
    GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")

    MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end)