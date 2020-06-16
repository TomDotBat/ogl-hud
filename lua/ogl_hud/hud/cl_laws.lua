
local showLaws = true

local nextPress = 0
hook.Add("PlayerButtonDown", "OGLHUD.ToggleLaws", function(ply, btn)
    if btn != KEY_F2 then return end
    if CurTime() < nextPress then return end

    showLaws = !showLaws

    nextPress = CurTime() + .2
end)

OGLFramework.UI.RegisterFont("HUD.LawTitle", "Montserrat SemiBold", 24)
OGLFramework.UI.RegisterFont("HUD.Laws", "Montserrat Medium", 20)

local lawPos = 0

hook.Add("HUDPaint", "OGLHUD.Laws", function()
    local scrw, scrh = ScrW(), ScrH()

    local pad = OGLFramework.UI.Scale(10)

    local laws = ""
    for k,v in ipairs(DarkRP.getLaws()) do
        laws = laws .. k .. ". " .. v .. "\n"
    end
    laws = string.Left(laws, #laws-1)

    surface.SetFont("OGL.HUD.Laws")
    local lawsw, lawsh = surface.GetTextSize(laws)

    local lH = lawsh + scrh * .053
    local lW = math.max(scrw * .04, lawsw + scrw * .015)

    lawPos = Lerp(FrameTime() * 10, lawPos, showLaws and pad or -lW * 1.2)

    draw.RoundedBox(4, lawPos, pad, lW, lH, OGLFramework.UI.ColourScheme.backgroundDarkerish)
    draw.RoundedBoxEx(4, lawPos, pad, lW, scrh * .03, OGLFramework.UI.ColourScheme.primary, true, true, false, false)

    draw.SimpleText("LAWS OF THE LAND (F2)", "OGL.HUD.LawTitle", lawPos + scrw * .007, pad + scrh * 0.004, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.DrawText(laws, "OGL.HUD.Laws", lawPos + scrw * 0.008, pad + scrh * 0.038, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT)
end)