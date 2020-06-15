
local alerts = {}

net.Receive("OGLHUD.Alert", function()
    local alert = {
        title = net.ReadString(),
        message = net.ReadString(),
        dietime = net.ReadUInt(16),
        alpha = 0
    }

    alerts[#alerts + 1] = alert
end)

local arrested = false
local timeLeft = 0

net.Receive("OGLHUD.Arrest", function()
    timeLeft = net.ReadUInt(32)

    timer.Create("OGLHUD.ArrestTimer", 1, timeLeft - 1, function()
        timeLeft = timeLeft - 1
    end)
end)

local batteryAlerted = false
local vehicleList = false
local vehicleName = false
local vehicleOwnership = ""

//Micro optimisations
local frametime = FrameTime
local lerp = Lerp
local drawtext = draw.SimpleText
local drawtextwrapped = draw.DrawText
local stringreplace = string.Replace
local scrw, scrh = 0, 0

hook.Add("Tick", "OGLHUD.Alerts", function()
    local ply = LocalPlayer()
    arrested = ply:getDarkRPVar("Arrested")

    if system.BatteryPower() < 10 and !batteryAlerted then
        alerts[#alerts + 1] = {
            title = "Low Battery",
            message = "Your system battery is low\nplease plug in a charger.",
            dietime = CurTime() + 30,
            alpha = 0
        }

        batteryAlerted = true

        timer.Simple(60, function()
            batteryAlerted = false
        end)
    end

    vehicleList = vehicleList or list.Get("Vehicles")

    if !ply:InVehicle() then
        local ent = ply:GetEyeTrace().Entity
        if IsValid(ent) and ent:IsVehicle() and ent:GetClass() != "prop_vehicle_prisoner_pod" then
            if ply:GetPos():DistToSqr(ent:GetPos()) < 40000 then
                local vehicleData = ent:getDoorData()
                vehicleName = ""
                vehicleOwnership = ""

                local vehicleClass = ent:GetVehicleClass()

                if vehicleData.title then
                    vehicleName = vehicleData.title
                elseif vehicleClass and vehicleList[vehicleClass] then
                    vehicleName = vehicleList[vehicleClass].Name
                else
                    vehicleName = "Vehicle"
                end

                if vehicleData.groupOwn then
                    vehicleOwnership = vehicleData.groupOwn
                elseif vehicleData.nonOwnable then
                    vehicleOwnership = "Not Ownable"
                elseif vehicleData.teamOwn then
                    vehicleOwnership = stringreplace("%J only", "%J", vehicleData.teamOwn)
                elseif vehicleData.owner then
                    local vehicleOwner = Player(vehicleData.owner)
                    if IsValid(vehicleOwner) then
                        vehicleOwnership = stringreplace("Owned by %N", "%N", vehicleOwner:Name())
                    else
                        vehicleOwnership = stringreplace("Owned by %N", "%N", "Unknown")
                    end
                else
                    vehicleOwnership = "Unowned"
                end
            else
                vehicleName = false
                vehicleOwnership = ""
            end
        else
            vehicleName = false
            vehicleOwnership = ""
        end
    else
        vehicleName = false
        vehicleOwnership = ""
    end

    scrw, scrh = ScrW(), ScrH()
end)

OGLFramework.UI.RegisterFont("HUD.AlertTitle", "Montserrat SemiBold", 32)
OGLFramework.UI.RegisterFont("HUD.AlertMessage", "Montserrat Medium", 24)
OGLFramework.UI.RegisterFont("HUD.ArrestTitle", "Montserrat SemiBold", 27)
OGLFramework.UI.RegisterFont("HUD.ArrestMessage", "Montserrat Medium", 22)
OGLFramework.UI.RegisterFont("HUD.VehicleTitle", "Montserrat SemiBold", 28)
OGLFramework.UI.RegisterFont("HUD.VehicleSubTitle", "Montserrat Medium", 23)

local smoothOutArrest = 0
hook.Add("HUDPaint", "OGLHUD.Alerts", function()
    local pad = OGLFramework.UI.Scale(10)
    local spacing = OGLFramework.UI.Scale(10)
    local yOff = pad
    local boxW = scrw * .28

    local ft = frametime() * 2
    local time = CurTime()
    for k,v in ipairs(alerts) do
        if time > v.dietime then
            v.alpha = math.max(v.alpha - ft, 0)

            if v.alpha == 0 then
                table.remove(alerts, k)
                continue
            end
        else
            v.alpha = math.min(v.alpha + ft, 1)
        end

        surface.SetAlphaMultiplier(v.alpha)

        surface.SetFont("OGL.HUD.AlertMessage")
        local msgw, msgh = surface.GetTextSize(v.message)
        local boxH = msgh + scrh * 0.05
        local thisBoxW = math.Max(boxW, msgw + scrw * .02)
        local xOff = scrw * .5 - thisBoxW * 0.5

        draw.RoundedBox(4, xOff, yOff, thisBoxW, boxH, OGLFramework.UI.ColourScheme.backgroundDarkerish)

        draw.RoundedBoxEx(4, xOff, yOff, thisBoxW, scrh * .034, OGLFramework.UI.ColourScheme.primary, true, true, false, false)

        drawtext(v.title, "OGL.HUD.AlertTitle", xOff + thisBoxW * .5, yOff + scrh * 0.016, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        drawtextwrapped(v.message, "OGL.HUD.AlertMessage", xOff + thisBoxW * .5, yOff + scrh * 0.04, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER)

        yOff = yOff + boxH + spacing

        surface.SetAlphaMultiplier(1)
    end

    ft = ft * 4
    smoothOutArrest = lerp(ft, smoothOutArrest, arrested and 0 or scrh * .15)

    local arrestText = stringreplace("Arrested: You will be released in %s seconds.", "%s", timeLeft)

    surface.SetFont("OGL.HUD.ArrestMessage")
    local msgw = surface.GetTextSize(arrestText)

    boxW, boxH = math.Max(scrw * .18, msgw + scrw * .02), OGLFramework.UI.Scale(50)
    local xOff = ScrW() - boxW - pad

    yOff = smoothOutArrest + scrh - pad - boxH

    draw.RoundedBox(4, xOff, yOff, boxW, boxH, OGLFramework.UI.ColourScheme.backgroundDarkerish)

    draw.RoundedBoxEx(4, xOff, yOff, boxW, OGLFramework.UI.Scale(6), OGLFramework.UI.ColourScheme.primary, true, true, false, false)

    drawtext(arrestText, "OGL.HUD.ArrestMessage", xOff + boxW * .5, yOff + scrh * 0.014, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    if !vehicleName then return end
    surface.SetFont("OGL.HUD.VehicleTitle")
    local nameTextWidth = surface.GetTextSize(vehicleName)

    surface.SetFont("OGL.HUD.VehicleSubTitle")
    local ownerTextWidth = surface.GetTextSize(vehicleOwnership)

    local offY = scrh * .3
    boxW, boxH = math.max(nameTextWidth, ownerTextWidth) + scrw * .015, scrh * .05

    draw.RoundedBox(4, scrw / 2 - boxW / 2, scrh / 2 + offY - boxH, boxW, boxH, OGLFramework.UI.ColourScheme.backgroundDarkerish)

    draw.RoundedBoxEx(4, scrw / 2 - boxW / 2, scrh / 2 + offY - boxH, boxW, boxH * .5, OGLFramework.UI.ColourScheme.primary, true, true, false, false)

    drawtext(vehicleName, "OGL.HUD.VehicleTitle", scrw / 2, offY + scrh / 2 - boxH * 1.04, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    drawtext(vehicleOwnership, "OGL.HUD.VehicleSubTitle", scrw / 2, offY + scrh / 2 - boxH * .05, OGLFramework.UI.ColourScheme.lightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)