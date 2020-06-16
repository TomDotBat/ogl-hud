
local renderPlayers = {}

//Micro optimisations
local drawtext = draw.SimpleText
local playergetall = player.GetAll

hook.Add("Tick", "OGLHUD.Overheads", function()
    local ply = LocalPlayer()

    renderPlayers = {}

    local plypos = ply:GetPos()
    for k,v in ipairs(playergetall()) do
        if v == ply then continue end
        if plypos:DistToSqr(v:GetPos()) < 90000 or v:IsSpeaking() then
            table.insert(renderPlayers, v)
        end
    end
end)

local typingMat
local speakingMat
local wantedMat

OGLFramework.UI.Register3D2DFont("HUD.OverheadName", "Montserrat SemiBold", 70)

hook.Add("PostDrawTranslucentRenderables", "OGLHUD.Overheads", function()
    local ply = LocalPlayer()

    local previousClip = DisableClipping(true)

    local plyInVehicle = ply:InVehicle()
    local eyeAngs = ply:EyeAngles()

    for k,v in ipairs(renderPlayers) do
        if not IsValid(v) then continue end
        if v:Health() < 1 then continue end
        if v:GetColor().a < 100 or v:GetNoDraw() then continue end

        local eyeId = v:LookupAttachment("eyes")
        local offset = Vector(0, 0, 85)
        local ang  = v:EyeAngles()
        local pos

        if not eyeId then
            pos = (v:GetPos() + offset + ang:Up())
        else
            local eyes = v:GetAttachment(eyeId)
            if not eyes then
                pos = (v:GetPos() + offset + ang:Up())
            else
                offset = Vector(0, 0, 15)
                pos = (eyes.Pos + offset)
            end
        end

        cam.Start3D2D(pos, plyInVehicle and Angle(0,ply:GetVehicle():GetAngles().y + eyeAngs.y - 90,90) or Angle(0,eyeAngs.y - 90,90), 0.06)
            local rank = "G2"
            local name = v:Name()

            surface.SetFont("OGL.HUD.OverheadName")
            local nw = surface.GetTextSize(name)

            if rank then
                local rw = surface.GetTextSize(rank)
                nw = nw + 20 + rw
                local rx = -nw / 2
                draw.RoundedBox(0, rx + rw + 7, 14, 3, 48, OGLFramework.UI.ColourScheme.primary)
                drawtext(rank, "OGL.HUD.OverheadName", rx, 0, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            drawtext(name, "OGL.HUD.OverheadName", nw / 2, 0, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

            local healthw = nw * v:Health() / 100
            draw.RoundedBox(0, -healthw / 2, 75, healthw, 6, OGLFramework.UI.ColourScheme.negative)

            local armorw = nw * v:Armor() / 255
            draw.RoundedBox(0, -armorw / 2, 90, armorw, 6, OGLFramework.UI.ColourScheme.primary)

            if v:IsTyping() then
                surface.SetMaterial(typingMat)
            elseif v:IsSpeaking() then
                surface.SetMaterial(speakingMat)
            elseif v:getDarkRPVar("wanted") then
                surface.SetMaterial(wantedMat)
            else
                cam.End3D2D()
                continue
            end

            local iconSize = 140

            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(-iconSize / 2, -150, iconSize, iconSize)
        cam.End3D2D()
    end

    DisableClipping(previousClip)
end)

hook.Add("Initialize", "FLATHUDHideTypeIndicator",function()
    hook.Remove("StartChat", "StartChatIndicator")
    hook.Remove("FinishChat", "EndChatIndicator")
    hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
end)

hook.Remove("PostDrawTranslucentRenderables", "FLATHUDShowOverhead")