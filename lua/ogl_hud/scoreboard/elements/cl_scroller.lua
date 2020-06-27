
local PANEL = {}

function PANEL:Init()

    self.VBar:SetHideButtons(true)

    function self.VBar:Paint(w, h) end

    function self.VBar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, (self:IsHovered() or self:GetParent().Dragging) and OGLFramework.UI.ColourScheme.backgroundDark or OGLFramework.UI.ColourScheme.background)
    end

    self.Players = {}
end

function PANEL:RefreshPlayers()
    self:Clear()
    table.Empty(self.Players)

    for k,v in ipairs(player.GetAll()) do
        self:AddPlayer(v)
    end
end

function PANEL:AddPlayer(ply)
    local nextPly = self:Add("OGLScoreboard.Player")
    nextPly:SetPlayer(ply)
    nextPly.PlayerList = self

    table.insert(self.Players, nextPly)
end

function PANEL:RemovePlayer(pnl)
    pnl:Remove()
    table.RemoveByValue(self.Players, pnl)
end

function PANEL:PerformLayout(w, h)
    local Tall = self.pnlCanvas:GetTall()
    local Wide = self:GetWide()
    local YPos = 0

    self:Rebuild()

    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    YPos = self.VBar:GetOffset()

    if self.VBar.Enabled then Wide = Wide - self.VBar:GetWide() end

    self.pnlCanvas:SetPos(0, YPos)
    self.pnlCanvas:SetWide(Wide)

    self:Rebuild()

    if Tall != self.pnlCanvas:GetTall() then
        self.VBar:SetScroll(self.VBar:GetScroll())
    end

    local playerH = OGLFramework.UI.Scale(60)
    local playerSpacing = OGLFramework.UI.Scale(12)

    local dockPadRight = self.VBar.Enabled and OGLFramework.UI.Scale(10) or 0

    for k, v in ipairs(self.Players) do
        v:SetTall(playerH)
        v:DockMargin(0, 0, dockPadRight, playerSpacing)
        v:Dock(TOP)
    end
end

vgui.Register("OGLScoreboard.Scroller", PANEL, "DScrollPanel")