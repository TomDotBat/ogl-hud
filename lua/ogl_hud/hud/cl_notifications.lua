
local notifications = {}

local frametime = FrameTime
local padding = OGLFramework.UI.Scale(10)
local spacing = OGLFramework.UI.Scale(10)

local imgurIds = {
    [NOTIFY_CLEANUP] = "JDcSoBi",
    [NOTIFY_ERROR] = "h0hUIfp",
    [NOTIFY_GENERIC] = "Lf7OfXA",
    [NOTIFY_HINT] = "97g11hD",
    [NOTIFY_UNDO] = "a6hsmHV"
}

local notifMats = {}

for k,v in pairs(imgurIds) do
    OGLFramework.UI.GetImgur(v, function(mat)
        notifMats[k] = mat
    end)
end

local function getYOff()
    return ScrH() - OGLFramework.UI.Scale(150)
end

function notification.AddLegacy(text, type, time)
    local notif = {
        text = text,
        type = type,
        dietime = CurTime() + time,
        x = ScrW(),
        y = getYOff()
    }

    notifications[#notifications + 1] = notif
end

function notification.AddProgress(id, text, frac) end

function notification.Kill(id) end

OGLFramework.UI.RegisterFont("HUD.Notification", "Montserrat Medium", 22)

hook.Add("HUDPaint", "OGLHUD.Notifications", function()
    local scrw, scrh = ScrW(), ScrH()

    local offX = scrw - padding
    local offY = getYOff()

    local ft = frametime() * 10
    local time = CurTime()

    local nh = scrh * .038

    surface.SetFont("OGL.HUD.Notification")

    for k,v in ipairs(notifications) do
        local nw = nh + surface.GetTextSize(v.text) + scrw * .005
        local desiredx, desiredy = offX-nw, offY-((nh * k) + (spacing * (k - 1)))

        if time >= v.dietime then
            v.x = Lerp(ft, v.x, scrw + nw * .1)

            if v.x > scrw then
                table.remove(notifications, k)
                continue
            end
        else
            v.x = Lerp(ft, v.x, desiredx)
        end
        v.y = Lerp(ft, v.y, desiredy)

        draw.RoundedBoxEx(OGLFramework.UI.Scale(6), v.x, v.y, nw, nh, OGLFramework.UI.ColourScheme.backgroundDarkerish, false, false, true, true)

        local halfOverlineH = OGLFramework.UI.Scale(3)
        draw.RoundedBox(halfOverlineH, v.x, v.y - halfOverlineH, nw, OGLFramework.UI.Scale(4), OGLFramework.UI.ColourScheme.primary)

        draw.SimpleText(v.text, "OGL.HUD.Notification", v.x + nw - scrw * .005, v.y + nh * .47, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        local iconSize = nh * .6

        local iconOff = nh * .18
        local iconOffX = OGLFramework.UI.Scale(10)
        surface.SetDrawColor(OGLFramework.UI.ColourScheme.lightText)
        surface.SetMaterial(notifMats[v.type])
        surface.DrawTexturedRect(iconOffX + v.x, iconOff + v.y + nh * .05, iconSize, iconSize)
    end
end)