
local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrH() * .84, ScrH() * .84)
    self:Center()
    self:ParentToHUD()

    self:MakePopup()
    self:SetKeyboardInputEnabled(false)

    self.PlayerCount = player.GetCount()
    self.MaxPlayers = game.MaxPlayers()

    self.Scroller = vgui.Create("OGLScoreboard.Scroller", self)
end

function PANEL:Think()
    self.PlayerCount = player.GetCount()
end

function PANEL:PerformLayout(w, h)
    local pad = OGLFramework.UI.Scale(14)
    self:DockPadding(pad, OGLFramework.UI.Scale(50) + pad, pad, pad)

    if not (self.Scroller or IsValid(self.Scroller)) then return end
    self.Scroller:Dock(FILL)
    self.Scroller:Rebuild()
end

OGLFramework.UI.RegisterFont("Scoreboard.Title", "Montserrat SemiBold", 32)

function PANEL:Paint(w, h)
    draw.RoundedBox(10, 0, 0, w, h, OGLFramework.UI.ColourScheme.backgroundDarkerish)

    local headerH = OGLFramework.UI.Scale(50)
    draw.RoundedBoxEx(10, 0, 0, w, headerH, OGLFramework.UI.ColourScheme.primary, true, true)
    draw.SimpleText("OGL NETWORK - " .. self.PlayerCount .. "/" .. self.MaxPlayers .. " PLAYERS ONLINE", "OGL.Scoreboard.Title", OGLFramework.UI.Scale(14), headerH * .48, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("OGLScoreboard", PANEL, "Panel")