
local doorCache = {}
local drawDoors = {}
local opposite = Angle(0,180,0)

local drawtext = draw.SimpleText
local stringreplace = string.Replace

OGLFramework.UI.Register3D2DFont("HUD.DoorLarge", "Montserrat SemiBold", 140)
OGLFramework.UI.Register3D2DFont("HUD.DoorMedium", "Montserrat Medium", 95)
OGLFramework.UI.Register3D2DFont("HUD.DoorSmall", "Montserrat Medium", 65)

local function drawDoor(displayData, doorHeader, doorSubHeader, extraText)
	local half = displayData.canvasWidth / 2

	drawtext(doorHeader, "OGL.HUD.DoorLarge", half, -60, color_white, TEXT_ALIGN_CENTER)

	drawtext(doorSubHeader, "OGL.HUD.DoorMedium", half, 80, color_white, TEXT_ALIGN_CENTER)

	for k,v in ipairs(extraText) do
		drawtext(v, "OGL.HUD.DoorSmall", half, 120 + k * 60, color_white, TEXT_ALIGN_CENTER)
	end
end

local function draw3D2DDoor(door)
	local displayData = {}
	local doorAngles = door:GetAngles()

	if doorCache[door] then
		displayData = doorCache[door]
	else
		local OBBMaxs = door:OBBMaxs()
		local OBBMins = door:OBBMins()
		local OBBCenter = door:OBBCenter()

		local size = OBBMins - OBBMaxs
		size = Vector(math.abs(size.x), math.abs(size.y), math.abs(size.z))

		local obbCenterToWorld = door:LocalToWorld(OBBCenter)

		local traceTbl = {
			endpos = obbCenterToWorld,
			filter = function( ent )
				return !(ent:IsPlayer() or ent:IsWorld())
			end
		}

		local offset
		local DrawAngles
		local CanvasPos1
		local CanvasPos2

		if size.x > size.y then
			DrawAngles = Angle(0,0,90)
			traceTbl.start = obbCenterToWorld + door:GetRight() * (size.y / 2)
			offset = Vector(size.x / 2, util.TraceLine(traceTbl).Fraction * (size.y / 2) + 0.85,0)

		else
			DrawAngles = Angle(0,90,90)
			traceTbl.start = obbCenterToWorld + door:GetForward() * (size.x / 2)
			offset = Vector(-((1 - util.TraceLine(traceTbl).Fraction) * (size.x / 2) + 0.85), size.y / 2,0)

		end

		local heightOffset = Vector(0,0,15)
		CanvasPos1 = OBBCenter - offset + heightOffset
		CanvasPos2 = OBBCenter + offset + heightOffset

		local scale = 0.04
		local canvasWidth

		if size.x > size.y then
			canvasWidth = size.x / scale
		else
			canvasWidth = size.y / scale
		end

		displayData = {
			DrawAngles = DrawAngles,
			CanvasPos1 = CanvasPos1,
			CanvasPos2 = CanvasPos2,
			scale = scale,
			canvasWidth = canvasWidth,
			start = traceTbl.start
		}
		doorCache[door] = displayData
	end

	local doorData = door:getDoorData()

	local doorHeader = ""
	local doorSubHeader = ""
	local extraText = {}

	if table.Count(doorData) > 0 then
		if doorData.groupOwn then
			doorHeader = doorData.groupOwn
		elseif doorData.nonOwnable then
			doorHeader = doorData.title or ""
		elseif doorData.teamOwn then
			doorHeader = doorData.title or "Job Door"
			doorSubHeader = stringreplace("Access: %J job(s)", "%J", table.Count(doorData.teamOwn))

			for k,_ in pairs(doorData.teamOwn) do
				table.insert(extraText, team.GetName(k))
			end
		elseif doorData.owner then
			doorHeader = doorData.title or "Owned"

			local doorOwner = Player(doorData.owner)
			if IsValid(doorOwner) then
				doorSubHeader = stringreplace("Owner: %N", "%N", doorOwner:Name())
			else
				doorSubHeader = "Owner: Unknown"
			end

			if doorData.allowedToOwn then
				for k,v in pairs(doorData.allowedToOwn) do
					doorData.allowedToOwn[k] = Player(k)
					if !IsValid(doorData.allowedToOwn[k]) then
						doorData.allowedToOwn[k] = nil
					end
				end

				if table.Count(doorData.allowedToOwn) > 0 then
					table.insert(extraText, "Allowed Co-Owners:")

					for k,v in pairs(doorData.allowedToOwn) do
						table.insert(extraText, v:Name())
					end

					table.insert(extraText, "")
				end
			end

			if doorData.extraOwners then
				for k,v in pairs(doorData.extraOwners) do
					doorData.extraOwners[k] = Player(k)
					if !IsValid(doorData.extraOwners[k]) then
						doorData.extraOwners[k] = nil
					end
				end

				if table.Count(doorData.extraOwners) > 0 then
					table.insert(extraText, "Co-Owners:")

					for k,v in pairs(doorData.extraOwners) do
						table.insert(extraText,v:Name())
					end
				end
			end
		end
	else
		doorHeader = "For Sale"
		doorSubHeader = "Press F2 to purchase"
	end

	doorHeader = string.Left(doorHeader, 25)
	doorSubHeader = string.Left(doorSubHeader, 35)

	cam.Start3D()
		cam.Start3D2D(door:LocalToWorld(displayData.CanvasPos1), displayData.DrawAngles + doorAngles, displayData.scale)
			drawDoor(displayData, doorHeader, doorSubHeader, extraText)
		cam.End3D2D()

		cam.Start3D2D(door:LocalToWorld(displayData.CanvasPos2), displayData.DrawAngles + doorAngles + opposite, displayData.scale)
			drawDoor(displayData, doorHeader, doorSubHeader, extraText)
		cam.End3D2D()
	cam.End3D()
end

local ply = LocalPlayer()
hook.Add("Tick", "OGLHUD.Doors", function()
	table.Empty(drawDoors)
	for k,v in ipairs(ents.FindInSphere(ply:EyePos(), 250)) do
		if v:isDoor() and v:GetClass() != "prop_dynamic" and !v:GetNoDraw() then
			drawDoors[#drawDoors + 1] = v
		end
	end
end)

hook.Add("RenderScreenspaceEffects", "OGLHUD.Doors", function()
	local previousClip = DisableClipping(true)

	for k,v in ipairs(drawDoors) do
		if !IsValid(v) then
			table.remove(drawDoors, k)
			continue
		end
		draw3D2DDoor(v)
	end

	DisableClipping(previousClip)
end)