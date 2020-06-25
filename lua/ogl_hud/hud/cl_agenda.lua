
local agenda = false
local agendaText = ""

local scrw, scrh = 0, 0
local ply = LocalPlayer()
local frametime = FrameTime
local lerp = Lerp
local drawtext = draw.SimpleText
local drawtextwrapped = draw.DrawText

hook.Add("Tick", "OGLHUD.Agenda", function()
    scrw, scrh = ScrW(), ScrH()

    agenda = ply:getAgendaTable()
    if not agenda then agenda = false return end
    agenda.Title = string.upper(agenda.Title)
    agendaText = DarkRP.textWrap((ply:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "OGL.HUD.AgendaDescription", 300)
end)

OGLFramework.UI.RegisterFont("HUD.AgendaTitle", "Montserrat SemiBold", 24)
OGLFramework.UI.RegisterFont("HUD.AgendaDescription", "Montserrat Medium", 20)

local smoothOutAgenda = 0

hook.Add("HUDPaint", "OGLHUD.Agenda", function()
    local ft = frametime() * 10
    local pad = OGLFramework.UI.Scale(10)

    smoothOutAgenda = lerp(ft, smoothOutAgenda, (not agenda or #agendaText < 1) and scrw * .24 or 0)

    surface.SetFont("OGL.HUD.AgendaDescription")
    local textw, texth = surface.GetTextSize(agendaText)

    local agendaW = math.Max(scrw * .15, textw + scrw * .03)
    local agendaH = texth + scrh * .052
    local agendaX = scrw - agendaW - pad
    local agendaY = pad

    draw.RoundedBox(4, smoothOutAgenda + agendaX, agendaY, agendaW, agendaH, OGLFramework.UI.ColourScheme.backgroundDarkerish)
    draw.RoundedBoxEx(4, smoothOutAgenda + agendaX, agendaY, agendaW, scrh * .03, OGLFramework.UI.ColourScheme.primary, true, true, false, false)

    if not agenda then return end
    drawtext(agenda.Title, "OGL.HUD.AgendaTitle", smoothOutAgenda + agendaX + scrw * .006, agendaY + scrh * .004, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    drawtextwrapped(agendaText, "OGL.HUD.AgendaDescription", smoothOutAgenda + agendaX + agendaW * .5, agendaY + scrh * .038, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
end)