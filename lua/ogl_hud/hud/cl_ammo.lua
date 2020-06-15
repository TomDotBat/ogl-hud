
OGLFramework.UI.RegisterFont("HUD.AmmoCount", "Montserrat Medium", 35)

local ammoY = ScrH()

hook.Add("HUDPaint", "OGLHUD.Ammo", function()
    local ply = LocalPlayer()

    local ammoW, ammoH = OGLFramework.UI.Scale(130), OGLFramework.UI.Scale(53)
    local padding = OGLFramework.UI.Scale(10)

    local curWeapon = ply:GetActiveWeapon()
    local shouldDrawAmmo = false
    local clip = 0
    local maxClip = 100

    if IsValid(curWeapon) then
        shouldDrawAmmo = true
        clip = curWeapon:Clip1()
        maxClip = tostring(ply:GetAmmoCount(curWeapon:GetPrimaryAmmoType()))
        if clip < 0 then shouldDrawAmmo = false end
    end

    local ammoX = ScrW() - padding - ammoW
    ammoY = Lerp(FrameTime() * 10, ammoY, shouldDrawAmmo and ScrH() - padding - ammoH or ScrH())

    draw.RoundedBox(OGLFramework.UI.Scale(6), ammoX, ammoY, ammoW, ammoH, OGLFramework.UI.ColourScheme.backgroundDarkerish)

    local overlineH = OGLFramework.UI.Scale(6)
    draw.RoundedBoxEx(OGLFramework.UI.Scale(3), ammoX, ammoY, ammoW, overlineH, OGLFramework.UI.ColourScheme.primary, true, true)

    ammoH = ammoH - overlineH

    draw.SimpleText(clip .. "/" .. maxClip, "OGL.HUD.AmmoCount", ammoX + ammoW / 2, ammoY + overlineH + ammoH * .45, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)