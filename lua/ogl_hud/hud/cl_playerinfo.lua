
local modules = {
    {
        name = "health",
        type = "bar",
        imgurID = "6pNpMN3",
        value = 0,
        getter = function(ply)
            return ply:Health()
        end
    },
    {
        name = "armour",
        type = "bar",
        imgurID = "9XHFdDQ",
        value = 0,
        getter = function(ply)
            return ply:Armor()
        end
    },
    {
        name = "name",
        type = "text",
        imgurID = "x5vBIvp",
        getter = function(ply)
            return ply:Name()
        end
    },
    {
        name = "job",
        type = "text",
        imgurID = "gevoGAg",
        getter = function(ply)
            return team.GetName(ply:Team())
        end
    },
    {
        name = "wallet",
        type = "num",
        imgurID = "gnNVKW0",
        formatMoney = true,
        actualValue = 0,
        getter = function(ply)
            return ply:getDarkRPVar("money")
        end
    },
    {
        name = "gpoints",
        type = "num",
        imgurID = "wT2iKhJ",
        actualValue = 0,
        getter = function(ply)
            return ply:GetGPoints()
        end
    },
    {
        name = "gunlicense",
        type = "icon",
        color = color_white,
        imgurID = "3uLFpU0",
        getter = function(ply)
            return ply:getDarkRPVar("HasGunlicense")
        end
    },
    {
        name = "lockdown",
        type = "icon",
        color = OGLFramework.UI.ColourScheme.negative,
        imgurID = "2lZmvvr",
        getter = function(ply)
            return GetGlobalBool("DarkRP_LockDown")
        end
    },
    {
        name = "wanted",
        type = "icon",
        color = OGLFramework.UI.ColourScheme.negative,
        imgurID = "oymFsE9",
        getter = function(ply)
            return ply:getDarkRPVar("wanted")
        end
    }
}

for k,v in pairs(modules) do
    OGLFramework.UI.GetImgur(v.imgurID, function(mat)
        modules[k].icon = mat
    end)
end

OGLFramework.UI.RegisterFont("HUD.PlayerInfo", "Montserrat SemiBold", 23)
OGLFramework.UI.RegisterFont("HUD.ServerName", "Montserrat SemiBold", 27)

local serverName = "OGL Network"

hook.Add("HUDPaint", "OGLHUD.PlayerInfo", function()
    local ply = LocalPlayer()

    local padding = OGLFramework.UI.Scale(10)
    local spacing = OGLFramework.UI.Scale(8)
    local barW = padding + spacing

    local statBarW = OGLFramework.UI.Scale(150)
    local iconSize = OGLFramework.UI.Scale(22)
    local iconSpacing = OGLFramework.UI.Scale(5)

    local barH = OGLFramework.UI.Scale(50)
    local barY = ScrH() - padding - barH
    local overlineH = OGLFramework.UI.Scale(6)
    local halfOverlineH = OGLFramework.UI.Scale(3)
    local contentH = barH - halfOverlineH
    local contentY = barY + halfOverlineH + contentH * .125
    contentH = contentH * .75

    surface.SetFont("OGL.HUD.PlayerInfo")
    for k,v in ipairs(modules) do
        if not v.icon then return end

        v.pos = barW

        if v.type == "bar" then
            v.noDraw = false
            v.value = Lerp(FrameTime() * 5, v.value, v.getter(ply))
            v.max = v.name == "armour" and 255 or ply:GetMaxHealth()

            if v.value > v.max then v.max = v.value end

            if v.name == "armour" and v.value < 1 then
                v.noDraw = true
                continue
            end

            barW = barW + statBarW + spacing
        elseif v.type == "text" then
            v.value = v.getter(ply)

            v.width = iconSize + iconSpacing * 3 + surface.GetTextSize(v.value)
            barW = barW + v.width + spacing
        elseif v.type == "icon" then
            v.noDraw = not v.getter(ply)
            if v.noDraw then continue end

            barW = barW + contentH + spacing
        elseif v.type == "num" then
            v.actualValue = Lerp(FrameTime() * 5, v.actualValue, v.getter(ply))
            v.value = math.Round(v.actualValue)

            if v.formatMoney then
                v.value = DarkRP.formatMoney(v.value)
            else
                v.value = string.Comma(v.value)
            end

            v.width = iconSize + iconSpacing * 3 + surface.GetTextSize(v.value)
            barW = barW + v.width + spacing
        end
    end

    surface.SetFont("OGL.HUD.ServerName")
    local serverNameW = surface.GetTextSize(serverName)
    barW = barW + serverNameW

    draw.RoundedBoxEx(OGLFramework.UI.Scale(6), padding, barY, barW, barH, OGLFramework.UI.ColourScheme.backgroundDarkerish, false, false, true, true)
    draw.RoundedBox(halfOverlineH, padding, barY - halfOverlineH, barW, overlineH, OGLFramework.UI.ColourScheme.primary)

    local iconY = contentY + OGLFramework.UI.Scale(8)

    for k,v in ipairs(modules) do
        if v.noDraw then continue end

        if v.type == "bar" then
            draw.RoundedBox(OGLFramework.UI.Scale(6), v.pos, contentY, statBarW, contentH, OGLFramework.UI.ColourScheme.background)
            draw.RoundedBox(OGLFramework.UI.Scale(6), v.pos, contentY, statBarW * v.value / v.max, contentH, OGLFramework.UI.ColourScheme.primary)

            surface.SetMaterial(v.icon)
            surface.SetDrawColor(OGLFramework.UI.ColourScheme.lightText)
            surface.DrawTexturedRect(v.pos + iconSpacing, iconY, iconSize, iconSize)

            draw.SimpleText(math.Round(v.value) .. "%", "OGL.HUD.PlayerInfo", v.pos + iconSize + iconSpacing * 2, contentY + contentH / 2, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            continue
        elseif v.type == "icon" then
            draw.RoundedBox(OGLFramework.UI.Scale(6), v.pos, contentY, contentH, contentH, OGLFramework.UI.ColourScheme.background)

            surface.SetMaterial(v.icon)
            surface.SetDrawColor(v.color)
            surface.DrawTexturedRect(v.pos + iconSpacing + OGLFramework.UI.Scale(2), iconY, iconSize, iconSize)
            continue
        end

        draw.RoundedBox(OGLFramework.UI.Scale(6), v.pos, contentY, v.width, contentH, OGLFramework.UI.ColourScheme.background)

        surface.SetMaterial(v.icon)
        surface.SetDrawColor(OGLFramework.UI.ColourScheme.lightText)
        surface.DrawTexturedRect(v.pos + iconSpacing, iconY, iconSize, iconSize)

        draw.SimpleText(v.value, "OGL.HUD.PlayerInfo", v.pos + iconSize + iconSpacing * 2, contentY + contentH / 2, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText(serverName, "OGL.HUD.ServerName", padding + barW - serverNameW - OGLFramework.UI.Scale(10), contentY + contentH * .45, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)