local QuestionVGUI = {}
local PanelNum = 0
local VoteVGUI = {}
local function MsgDoVote(msg)
    local _, chatY = chat.GetChatBoxPos()

    local question = msg:ReadString()
    local voteid = msg:ReadShort()
    local timeleft = msg:ReadFloat()
    if timeleft == 0 then
        timeleft = 100
    end
    local OldTime = CurTime()
    if not IsValid(LocalPlayer()) then return end -- Sent right before player initialisation

    LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
    local panel = vgui.Create("DFrame")
    panel:SetPos(OGLFramework.UI.Scale(10) + PanelNum, ScrH()*0.3)
    panel:SetSize(190, 190)
    panel:SetSizable(false)
    panel.btnClose:SetVisible(false)
    panel.btnMaxim:SetVisible(false)
    panel.btnMinim:SetVisible(false)
    panel:SetDraggable(false)
    panel:SetKeyboardInputEnabled(false)
    panel:SetMouseInputEnabled(true)
    panel:SetVisible(true)
    panel:SetTitle("")

    function panel:Close()
        PanelNum = PanelNum - 200
        VoteVGUI[voteid .. "vote"] = nil

        local num = 0
        for _, v in SortedPairs(VoteVGUI) do
            v:SetPos(OGLFramework.UI.Scale(10) + num, ScrH()*0.3)
            num = num + 140
        end

        for _, v in SortedPairs(QuestionVGUI) do
            v:SetPos(OGLFramework.UI.Scale(10) + num, ScrH()*0.3)
            num = num + 300
        end
        self:Remove()
    end

    function panel:Think()
        if timeleft - (CurTime() - OldTime) <= 0 then
            panel:Close()
        end
    end

    for k,v in ipairs(string.Explode("\n", question)) do
        if (k == 1) then
            question = v .. "\n"
        else
            question = question .. " " .. v
        end
    end

    panel.question = DarkRP.deLocalise(question)

    function panel:Paint(w, h)
        draw.RoundedBox( 4, 0, 0, w, h, OGLFramework.UI.ColourScheme.backgroundDark )
        draw.RoundedBoxEx( 4, 0, 0, w, h*.15, OGLFramework.UI.ColourScheme.primary, true, true, false, false )
        draw.SimpleText( "VOTE", "OGL.HUD.VoteTitle", w*0.5, h*0.004, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER )
        draw.DrawText(self.question, "OGL.HUD.VoteQuestion", w*0.5, h*0.18, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
        draw.DrawText(string.Replace("This vote expires in\n%s seconds", "%s", math.Round(OldTime + timeleft - CurTime())),  "OGL.HUD.VoteQuestion", w*0.5, h*0.52, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    end

    local ybutton = vgui.Create("Button")
    ybutton:SetParent(panel)
    ybutton:SetPos(10, 157)
    ybutton:SetSize(80, 23)
    ybutton:SetTextColor(OGLFramework.UI.ColourScheme.lightText)
    ybutton:SetFont("OGL.HUD.VoteButton")
    ybutton:SetCommand("!")
    ybutton:SetText("Yes")
    ybutton:SetVisible(true)

    function ybutton:DoClick()
        LocalPlayer():ConCommand("vote " .. voteid .. " yea\n")
        panel:Close()
    end

    function ybutton:Paint(w, h)
        draw.RoundedBox( 4, 0, 0, w, h, OGLFramework.UI.ColourScheme.positive )
    end

    local nbutton = vgui.Create("Button")
    nbutton:SetParent(panel)
    nbutton:SetPos(100, 157)
    nbutton:SetSize(80, 23)
    nbutton:SetTextColor(OGLFramework.UI.ColourScheme.lightText)
    nbutton:SetFont("OGL.HUD.VoteButton")
    nbutton:SetCommand("!")
    nbutton:SetText("No")
    nbutton:SetVisible(true)

    function nbutton:DoClick()
        LocalPlayer():ConCommand("vote " .. voteid .. " nay\n")
        panel:Close()
    end

    function nbutton:Paint(w, h)
        draw.RoundedBox( 4, 0, 0, w, h, OGLFramework.UI.ColourScheme.negative )
    end

    PanelNum = PanelNum + 200
    VoteVGUI[voteid .. "vote"] = panel
end
usermessage.Hook("DoVote", MsgDoVote)

local function KillVoteVGUI(msg)
    local id = msg:ReadShort()

    if VoteVGUI[id .. "vote"] and VoteVGUI[id .. "vote"]:IsValid() then
        VoteVGUI[id .. "vote"]:Close()
    end
end
usermessage.Hook("KillVoteVGUI", KillVoteVGUI)

local function MsgDoQuestion(msg)
    if not IsValid(LocalPlayer()) then return end

    local question = msg:ReadString()
    local quesid = msg:ReadString()
    local timeleft = msg:ReadFloat()
    if timeleft == 0 then
        timeleft = 100
    end
    local OldTime = CurTime()

    LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)

    local panel = vgui.Create("DFrame")
    panel:SetPos(OGLFramework.UI.Scale(10) + PanelNum, ScrH()*0.3) --{{ user_id sha256 key }}
    panel:SetSize(190, 190)
    panel:SetSizable(false)
    panel:ShowCloseButton(false)
    panel:SetKeyboardInputEnabled(false)
    panel:SetMouseInputEnabled(true)
    panel:SetVisible(true)
    panel:SetTitle("")

    function panel:Close()
        PanelNum = PanelNum - 200
        QuestionVGUI[quesid .. "ques"] = nil
        local num = 0
        for _, v in SortedPairs(VoteVGUI) do
            v:SetPos(OGLFramework.UI.Scale(10) + num, ScrH()*0.3)
            num = num + 140
        end

        for _, v in SortedPairs(QuestionVGUI) do
            v:SetPos(OGLFramework.UI.Scale(10) + num, ScrH()*0.3)
            num = num + 300
        end

        self:Remove()
    end

    function panel:Think()
        if timeleft - (CurTime() - OldTime) <= 0 then
            panel:Close()
        end
    end

    panel.question = DarkRP.deLocalise(question)

    function panel:Paint(w, h)
        draw.RoundedBox( 4, 0, 0, w, h, OGLFramework.UI.ColourScheme.backgroundDark )
        draw.RoundedBoxEx( 4, 0, 0, w, h*.15, OGLFramework.UI.ColourScheme.primary, true, true, false, false )
        draw.SimpleText( "QUESTION", "OGL.HUD.VoteTitle", w*0.5, h*0.004, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER )
        draw.DrawText(self.question, "OGL.HUD.VoteQuestion", w*0.5, h*0.18, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
        draw.DrawText(string.Replace("This expires in\n%s seconds", "%s", math.Round(OldTime + timeleft - CurTime())),  "OGL.HUD.VoteQuestion", w*0.5, h*0.52, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)
    end
    
    local ybutton = vgui.Create("DButton")
    ybutton:SetParent(panel)
    ybutton:SetPos(10, 157)
    ybutton:SetSize(80, 23)
    ybutton:SetTextColor(OGLFramework.UI.ColourScheme.lightText)
    ybutton:SetFont("OGL.HUD.VoteButton")
    ybutton:SetText("Yes")
    ybutton:SetVisible(true)

    function ybutton:DoClick()
        LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
        panel:Close()
    end

    function ybutton:Paint(w, h)
        draw.RoundedBox( 4, 0, 0, w, h, OGLFramework.UI.ColourScheme.positive )
    end

    local nbutton = vgui.Create("DButton")
    nbutton:SetParent(panel)
    nbutton:SetPos(100, 157)
    nbutton:SetSize(80, 23)
    nbutton:SetTextColor(OGLFramework.UI.ColourScheme.lightText)
    nbutton:SetFont("OGL.HUD.VoteButton")
    nbutton:SetText("No")
    nbutton:SetVisible(true)

    function nbutton:DoClick()
        LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
        panel:Close()
    end

    function nbutton:Paint(w, h)
        draw.RoundedBox( 4, 0, 0, w, h, OGLFramework.UI.ColourScheme.negative )
    end

    PanelNum = PanelNum + 200
    QuestionVGUI[quesid .. "ques"] = panel
end
usermessage.Hook("DoQuestion", MsgDoQuestion)

local function KillQuestionVGUI(msg)
    local id = msg:ReadString()

    if QuestionVGUI[id .. "ques"] and QuestionVGUI[id .. "ques"]:IsValid() then
        QuestionVGUI[id .. "ques"]:Close()
    end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)

local function DoVoteAnswerQuestion(ply, cmd, args)
    if not args[1] then return end

    local vote = 0
    if tonumber(args[1]) == 1 or string.lower(args[1]) == "yes" or string.lower(args[1]) == "true" then vote = 1 end --{{ user_id }}

    for k, v in pairs(VoteVGUI) do
        if IsValid(v) then
            local ID = string.sub(k, 1, -5)
            VoteVGUI[k]:Close()
            RunConsoleCommand("vote", ID, vote)
            return
        end
    end

    for k, v in pairs(QuestionVGUI) do
        if IsValid(v) then
            local ID = string.sub(k, 1, -5)
            QuestionVGUI[k]:Close()
            RunConsoleCommand("ans", ID, vote)
            return
        end
    end
end
concommand.Add("rp_vote", DoVoteAnswerQuestion)