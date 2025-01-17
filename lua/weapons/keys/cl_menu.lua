local function AddButtonToFrame(Frame)
    Frame:SetTall(Frame:GetTall() + 52)

    local button = vgui.Create("DButton", Frame)
    button:SetPos(10, Frame:GetTall() - 52)
    button:SetSize(180, 42)
    button:SetText("")

    function button:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, OGLFramework.UI.ColourScheme.primary)

        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, OGLFramework.UI.ColourScheme.primaryDark)
        end

        draw.SimpleText(self.text, "OGL.HUD.Button", w/2, h * .46, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    Frame.buttonCount = (Frame.buttonCount or 0) + 1
    Frame.lastButton = button
    return button
end

DarkRP.stub{
    name = "openKeysMenu",
    description = "Open the keys/F2 menu.",
    parameters = {},
    realm = "Client",
    returns = {},
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "onKeysMenuOpened",
    description = "Called when the keys menu is opened.",
    parameters = {
        {
            name = "ent",
            description = "The door entity.",
            type = "Entity"
        },
        { --{{ script_version_name }}
            name = "Frame",
            description = "The keys menu frame.",
            type = "Panel"
        }
    },
    returns = {
    },
    realm = "Client"
}

local KeyFrameVisible = false


local closeMat

OGLFramework.UI.GetImgur("4SSZN7x", function(mat)
    closeMat = mat
end)

local function openMenu(setDoorOwnerAccess, doorSettingsAccess)
    if KeyFrameVisible then return end
    local trace = LocalPlayer():GetEyeTrace()
    local ent = trace.Entity
    -- Don't open the menu if the entity is not ownable, the entity is too far away or the door settings are not loaded yet
    if not IsValid(ent) or not ent:isKeysOwnable() or trace.HitPos:DistToSqr(LocalPlayer():EyePos()) > 40000 then return end

    KeyFrameVisible = true
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(200, 46) -- Base size
    Frame.btnMaxim:SetVisible(false)
    Frame.btnMinim:SetVisible(false)
    Frame.btnClose:SetVisible(false)

    local closebtn = vgui.Create("DButton", Frame)
    closebtn:SetText("")
    closebtn:SetPos(169, 7)
    closebtn:SetSize(21, 21)
    closebtn.DoClick = function()
        Frame:Close()
    end
    function closebtn:Paint(w, h)
        surface.SetDrawColor(self:IsHovered() and OGLFramework.UI.ColourScheme.negativeDark or OGLFramework.UI.ColourScheme.negative)
        surface.SetMaterial(closeMat)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    Frame:SetVisible(true)
    Frame:MakePopup()
    Frame:ParentToHUD()

    function Frame:Think()
        local trace = LocalPlayer():GetEyeTrace()
        local LAEnt = trace.Entity
        if not IsValid(LAEnt) or not LAEnt:isKeysOwnable() or trace.HitPos:DistToSqr(LocalPlayer():EyePos()) > 40000 then
            self:Close()
        end
        if not self.Dragging then return end
        local x = gui.MouseX() - self.Dragging[1]
        local y = gui.MouseY() - self.Dragging[2]
        x = math.Clamp(x, 0, ScrW() - self:GetWide())
        y = math.Clamp(y, 0, ScrH() - self:GetTall())
        self:SetPos(x, y)
    end

    local entType = DarkRP.getPhrase(ent:IsVehicle() and "vehicle" or "door")
    Frame:SetTitle("")

    function Frame:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, OGLFramework.UI.ColourScheme.backgroundDarkerish)

        draw.RoundedBoxEx(4, 0, 0, w, 36, OGLFramework.UI.ColourScheme.primary, true, true, false, false)

        draw.SimpleText(string.upper(DarkRP.getPhrase("x_options", entType:gsub("^%a", string.upper))), "OGL.HUD.DermaTitle", 10, 17, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    function Frame:Close()
        KeyFrameVisible = false
        self:SetVisible(false)
        self:Remove()
    end

    -- All the buttons

    if ent:isKeysOwnedBy(LocalPlayer()) then
        local Owndoor = AddButtonToFrame(Frame)
        Owndoor.text = DarkRP.getPhrase("sell_x", entType)
        Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end

        local AddOwner = AddButtonToFrame(Frame)
        AddOwner.text = DarkRP.getPhrase("add_owner")
        AddOwner.DoClick = function()
            local menu = DermaMenu()
            menu.found = false
            for _, v in pairs(DarkRP.nickSortedPlayers()) do
                if not ent:isKeysOwnedBy(v) and not ent:isKeysAllowedToOwn(v) then
                    local steamID = v:SteamID()
                    menu.found = true
                    menu:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ao", steamID) end)
                end
            end
            if not menu.found then
                menu:AddOption(DarkRP.getPhrase("noone_available"), function() end)
            end
            menu:Open()
        end

        local RemoveOwner = AddButtonToFrame(Frame)
        RemoveOwner.text = DarkRP.getPhrase("remove_owner")
        RemoveOwner.DoClick = function()
            local menu = DermaMenu()
            for _, v in pairs(DarkRP.nickSortedPlayers()) do
                if (ent:isKeysOwnedBy(v) and not ent:isMasterOwner(v)) or ent:isKeysAllowedToOwn(v) then
                    local steamID = v:SteamID()
                    menu.found = true
                    menu:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ro", steamID) end)
                end
            end
            if not menu.found then
                menu:AddOption(DarkRP.getPhrase("noone_available"), function() end)
            end
            menu:Open()
        end
        if not ent:isMasterOwner(LocalPlayer()) then
            RemoveOwner:SetDisabled(true)
        end
    end

    if doorSettingsAccess then
        local DisableOwnage = AddButtonToFrame(Frame)
        DisableOwnage.text = DarkRP.getPhrase(ent:getKeysNonOwnable() and "allow_ownership" or "disallow_ownership")
        DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("darkrp", "toggleownable") end
    end

    if doorSettingsAccess and (ent:isKeysOwned() or ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or hasTeams) or ent:isKeysOwnedBy(LocalPlayer()) then
        local DoorTitle = AddButtonToFrame(Frame)
        DoorTitle.text = DarkRP.getPhrase("set_x_title", entType)
        DoorTitle.DoClick = function()
            Derma_StringRequest(DarkRP.getPhrase("set_x_title", entType), DarkRP.getPhrase("set_x_title_long", entType), "", function(text)
                RunConsoleCommand("darkrp", "title", text)
                if IsValid(Frame) then
                    Frame:Close()
                end
            end,
            function() end, DarkRP.getPhrase("ok"), DarkRP.getPhrase("cancel"))
        end
    end

    if not ent:isKeysOwned() and not ent:getKeysNonOwnable() and not ent:getKeysDoorGroup() and not ent:getKeysDoorTeams() or not ent:isKeysOwnedBy(LocalPlayer()) and ent:isKeysAllowedToOwn(LocalPlayer()) then --{{ user_id }}
        local Owndoor = AddButtonToFrame(Frame)
        Owndoor.text = DarkRP.getPhrase("buy_x", entType)
        Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end
    end

    if doorSettingsAccess then
        local EditDoorGroups = AddButtonToFrame(Frame)
        EditDoorGroups.text = DarkRP.getPhrase("edit_door_group")
        EditDoorGroups.DoClick = function()
            local menu = DermaMenu()
            local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
            local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
            local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
            local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

            menu:AddOption(DarkRP.getPhrase("none"), function()
                RunConsoleCommand("darkrp", "togglegroupownable")
                if IsValid(Frame) then Frame:Close() end
            end)

            for k in pairs(RPExtraTeamDoors) do
                groups:AddOption(k, function()
                    RunConsoleCommand("darkrp", "togglegroupownable", k)
                    if IsValid(Frame) then Frame:Close() end
                end)
            end

            local doorTeams = ent:getKeysDoorTeams()
            for k, v in pairs(RPExtraTeams) do
                local which = (not doorTeams or not doorTeams[k]) and add or remove
                which:AddOption(v.name, function()
                    RunConsoleCommand("darkrp", "toggleteamownable", k)
                    if IsValid(Frame) then Frame:Close() end
                end)
            end

            menu:Open()
        end
    end

    if Frame.buttonCount == 1 then
        Frame.lastButton:DoClick()
    elseif Frame.buttonCount == 0 or not Frame.buttonCount then
        Frame:Close()
        KeyFrameVisible = true
        timer.Simple(0.3, function() KeyFrameVisible = false end)
    end


    hook.Call("onKeysMenuOpened", nil, ent, Frame)

    Frame:Center()
end

function DarkRP.openKeysMenu(um)
    CAMI.PlayerHasAccess(LocalPlayer(), "DarkRP_SetDoorOwner", function(setDoorOwnerAccess)
        CAMI.PlayerHasAccess(LocalPlayer(), "DarkRP_ChangeDoorSettings", fp{openMenu, setDoorOwnerAccess})
    end)
end
usermessage.Hook("KeysMenu", DarkRP.openKeysMenu)