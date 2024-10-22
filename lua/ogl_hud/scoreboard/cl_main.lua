
OGLHUD.Ranks = {
    ["superadmin"] = {
        DisplayName = "Super Admin",
        Color = Color(152, 75, 189)
    }
}

OGLHUD.RainbowPlayers = {
    ["76561198215456356"] = true,
    ["76561198140026615"] = true
}

local function hideDefault()
    if not GAMEMODE then return end
    GAMEMODE.ScoreboardShow = nil
    GAMEMODE.ScoreboardHide = nil
end

hideDefault()

hook.Add("Initialize", "OGLHUD.HideDefaultScoreboard", hideDefault)
hook.Add("OnReloaded", "OGLHUD.HideDefaultScoreboard", hideDefault)

hook.Add("ScoreboardShow", "OGLHUD.ShowScoreboard", function()
    if OGLHUD.Scoreboard and OGLHUD.Scoreboard.Closing then return end

    if not IsValid(OGLHUD.Scoreboard) then
        OGLHUD.Scoreboard = vgui.Create("OGLScoreboard")
    end

    OGLHUD.Scoreboard:SetVisible(true)
    OGLHUD.Scoreboard.Scroller:RefreshPlayers()
    OGLHUD.Scoreboard:SetAlpha(0)
    OGLHUD.Scoreboard:AlphaTo(255, 0.1)
end)

hook.Add("ScoreboardHide", "OGLHUD.HideScoreboard", function()
    if not IsValid(OGLHUD.Scoreboard) then return end

    OGLHUD.Scoreboard.Closing = true
    OGLHUD.Scoreboard:AlphaTo(0, 0.1, 0, function(anim, pnl)
        pnl:Remove()
    end)
end)