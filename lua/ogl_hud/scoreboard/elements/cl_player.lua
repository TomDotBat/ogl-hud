
local PANEL = {}

local function formatPlaytime(time)
    local tmp = time
    tmp = math.floor(tmp / 60)
    tmp = math.floor(tmp / 60)
    local h = tmp % 24
    tmp = math.floor(tmp / 24)
    local d = tmp % 7
    local w = math.floor(tmp / 7)

    return string.format("%02iw %id %02ih", w, d, h)
end

local function formatSessionTime(time)
    local tmp = time
    tmp = math.floor(tmp / 60)
    local m = tmp % 60
    tmp = math.floor(tmp / 60)
    local h = tmp % 24
    tmp = math.floor(tmp / 24)

    return string.format("%02ih %02im", h, m)
end

function PANEL:UpdatePlayerData()
    local ply = self.Player
    if not (ply and IsValid(ply)) then
        self.PlayerList:RemovePlayer(self)
        return
    end

    local rank = ply:GetUserGroup()

    if OGLHUD.Ranks[rank] then
        self.Rank = OGLHUD.Ranks[rank].DisplayName
        self.RankColor = OGLHUD.Ranks[rank].Color
    else
        self.Rank = false
    end

    if OGLHUD.RainbowPlayers[ply:SteamID64()] then
        self.RainbowName = true
    end

    self.Name = ply:Name()
    self.Job = team.GetName(ply:Team())
    self.JobColor = team.GetColor(ply:Team())
    self.Money = ply:getDarkRPVar("money")
    self.KDRatio = ply:Frags() .. ":" .. ply:Deaths()
    self.Playtime = formatPlaytime(ply:GetUTimeTotalTime())
    self.SessionTime = formatSessionTime(ply:GetUTimeSessionTime())
    self.Ping = ply:Ping() .. "ms"
end

function PANEL:SetPlayer(ply)
    self.Player = ply

    self.Avatar = vgui.Create("OGLFramework.CircleAvatar", self)

    self.ProfileButton = vgui.Create("DButton", self.Avatar)
    self.ProfileButton:SetText("")

    function self.ProfileButton:Paint(w, h) end
    function self.ProfileButton:DoClick()
        gui.OpenURL("http://steamcommunity.com/profiles/" .. ply:SteamID64())
    end

    self.CopyIdButton = vgui.Create("DButton", self)
    self.CopyIdButton:SetText("")

    function self.CopyIdButton:Paint(w, h) end
    function self.CopyIdButton:DoClick()
        SetClipboardText(ply:SteamID())
        chat.AddText("Copied " .. ply:Name() .. "'s SteamID: " .. ply:SteamID())
    end

    self:UpdatePlayerData()
end

function PANEL:Think()
    if not self.Player then return end
    self:UpdatePlayerData()
end

function PANEL:PerformLayout(w, h)
    if not self.Player then return end

    local avatarSize = h * .75
    self.Avatar:SetPlayer(self.Player, avatarSize)
    self.Avatar:SetMaskSize(avatarSize * .5)
    self.Avatar:SetPos(OGLFramework.UI.Scale(8), (h - avatarSize) / 2)
    self.Avatar:SetSize(avatarSize, avatarSize)

    self.ProfileButton:Dock(FILL)

    self.CopyIdButton:SetPos(h, 0)
    self.CopyIdButton:SetSize(w * .15, h)
end

OGLFramework.UI.RegisterFont("Scoreboard.PlayerName", "Montserrat Medium", 26)
OGLFramework.UI.RegisterFont("Scoreboard.PlayerRank", "Montserrat Medium", 16)
OGLFramework.UI.RegisterFont("Scoreboard.ColumnName", "Montserrat Medium", 17)
OGLFramework.UI.RegisterFont("Scoreboard.ColumnStat", "Montserrat Medium", 22)

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, OGLFramework.UI.ColourScheme.backgroundDark)

    local textPad = h * .1
    local textBottom = h - textPad - h * .1

    local x = h * .75 + OGLFramework.UI.Scale(20)

    local name = OGLFramework.UI.EllipsesText(self.Name, OGLFramework.UI.Scale(w * .16), "OGL.Scoreboard.PlayerName")

    if self.Rank then
        draw.SimpleText(name, "OGL.Scoreboard.PlayerName", x, textPad, self.RainbowName and HSVToColor((CurTime() * 60) % 360, 1, 1) or OGLFramework.UI.ColourScheme.lightText)
        draw.SimpleText(self.Rank, "OGL.Scoreboard.PlayerRank", x, textBottom, self.RankColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    else
        draw.SimpleText(name, "OGL.Scoreboard.PlayerName", x, h * .46, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    x = x + w * .2

    textPad = h * .15
    textBottom = h - textPad

    draw.SimpleText("JOB", "OGL.Scoreboard.ColumnName", x, textPad, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.Job, "OGL.Scoreboard.ColumnStat", x, textBottom, self.JobColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    x = x + w * .13

    draw.SimpleText("MONEY", "OGL.Scoreboard.ColumnName", x, textPad, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    draw.SimpleText(DarkRP.formatMoney(self.Money), "OGL.Scoreboard.ColumnStat", x, textBottom, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    x = x + w * .12

    draw.SimpleText("K:D", "OGL.Scoreboard.ColumnName", x, textPad, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.KDRatio, "OGL.Scoreboard.ColumnStat", x, textBottom, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    x = x + w * .13

    draw.SimpleText("PLAYTIME", "OGL.Scoreboard.ColumnName", x, textPad, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.Playtime, "OGL.Scoreboard.ColumnStat", x, textBottom, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    x = x + w * .15

    draw.SimpleText("SESSION TIME", "OGL.Scoreboard.ColumnName", x, textPad, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.SessionTime, "OGL.Scoreboard.ColumnStat", x, textBottom, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    x = x + w * .12

    draw.SimpleText("PING", "OGL.Scoreboard.ColumnName", x, textPad, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.Ping, "OGL.Scoreboard.ColumnStat", x, textBottom, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

vgui.Register("OGLScoreboard.Player", PANEL, "Panel")