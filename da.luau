local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hubName = "Eclipse"
local hubVersion = 0
local myName = "sqwz"
local robloxUsername = "sqwaze_y"
local telegramUsername = "sqwzsqwz"

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = hubName .. " Hub",
	Author = "by " .. myName,
	ToggleKey = Enum.KeyCode.RightShift
})

-- Serializer repr ----------------------------------------------------
local defaultSettings = {
	pretty = true;
	robloxFullName = false;
	robloxProperFullName = true;
	robloxClassName = true;
	tabs = true;
	semicolons = false;
	spaces = 1;
	sortKeys = true;
}

-- lua keywords
local keywords = {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,
	["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true, ["function"]=true,
	["if"]=true, ["in"]=true, ["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
	["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true, ["until"]=true, ["while"]=true}

local function isLuaIdentifier(str)
	if type(str) ~= "string" then return false end
	-- must be nonempty
	if str:len() == 0 then return false end
	-- can only contain a-z, A-Z, 0-9 and underscore
	if str:find("[^%d%a_]") then return false end
	-- cannot begin with digit
	if tonumber(str:sub(1, 1)) then return false end
	-- cannot be keyword
	if keywords[str] then return false end
	return true
end

-- works like Instance:GetFullName(), but invalid Lua identifiers are fixed (e.g. workspace["The Dude"].Humanoid)
local function properFullName(object, usePeriod)
	if object == nil or object == game then return "" end

	local s = object.Name
	local usePeriod = true
	if not isLuaIdentifier(s) then
		s = ("[%q]"):format(s)
		usePeriod = false
	end

	if not object.Parent or object.Parent == game then
		return s
	else
		return properFullName(object.Parent) .. (usePeriod and "." or "") .. s 
	end
end

local depth = 0
local shown
local INDENT
local reprSettings

local function repr(value, reprSettings)
	reprSettings = reprSettings or defaultSettings
	INDENT = (" "):rep(reprSettings.spaces or defaultSettings.spaces)
	if reprSettings.tabs then
		INDENT = "\t"
	end

	local v = value --args[1]
	local tabs = INDENT:rep(depth)

	if depth == 0 then
		shown = {}
	end
	if type(v) == "string" then
		return ("%q"):format(v)
	elseif type(v) == "number" then
		if v == math.huge then return "math.huge" end
		if v == -math.huge then return "-math.huge" end
		return tonumber(v)
	elseif type(v) == "boolean" then
		return tostring(v)
	elseif type(v) == "nil" then
		return "nil"
	elseif type(v) == "table" and type(v.__tostring) == "function" then
		return tostring(v.__tostring(v))
	elseif type(v) == "table" and getmetatable(v) and type(getmetatable(v).__tostring) == "function" then
		return tostring(getmetatable(v).__tostring(v))
	elseif type(v) == "table" then
		if shown[v] then return "{CYCLIC}" end
		shown[v] = true
		local str = "{" .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or "")
		local isArray = true
		for k, v in pairs(v) do
			if type(k) ~= "number" then
				isArray = false
				break
			end
		end
		if isArray then
			for i = 1, #v do
				if i ~= 1 then
					str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
				end
				depth = depth + 1
				str = str .. repr(v[i], reprSettings)
				depth = depth - 1
			end
		else
			local keyOrder = {}
			local keyValueStrings = {}
			for k, v in pairs(v) do
				depth = depth + 1
				local kStr = isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]")
				local vStr = repr(v, reprSettings)
						--[[str = str .. ("%s = %s"):format(
							isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]"),
							repr(v, reprSettings)
						)]]
				table.insert(keyOrder, kStr)
				keyValueStrings[kStr] = vStr
				depth = depth - 1
			end
			if reprSettings.sortKeys then table.sort(keyOrder) end
			local first = true
			for _, kStr in pairs(keyOrder) do
				if not first then
					str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
				end
				str = str .. ("%s = %s"):format(kStr, keyValueStrings[kStr])
				first = false
			end
		end
		shown[v] = false
		if reprSettings.pretty then
			str = str .. "\n" .. tabs
		end
		str = str .. "}"
		return str
	elseif typeof then
		-- Check Roblox types
		if typeof(v) == "Instance" then
			return  (reprSettings.robloxFullName
				and (reprSettings.robloxProperFullName and properFullName(v) or v:GetFullName())
				or v.Name) .. (reprSettings.robloxClassName and ((" (%s)"):format(v.ClassName)) or "")
		elseif typeof(v) == "Axes" then
			local s = {}
			if v.X then table.insert(s, repr(Enum.Axis.X, reprSettings)) end
			if v.Y then table.insert(s, repr(Enum.Axis.Y, reprSettings)) end
			if v.Z then table.insert(s, repr(Enum.Axis.Z, reprSettings)) end
			return ("Axes.new(%s)"):format(table.concat(s, ", "))
		elseif typeof(v) == "BrickColor" then
			return ("BrickColor.new(%q)"):format(v.Name)
		elseif typeof(v) == "CFrame" then
			return ("CFrame.new(%s)"):format(table.concat({v:GetComponents()}, ", "))
		elseif typeof(v) == "Color3" then
			return ("Color3.new(%d, %d, %d)"):format(v.r, v.g, v.b)
		elseif typeof(v) == "ColorSequence" then
			if #v.Keypoints > 2 then
				return ("ColorSequence.new(%s)"):format(repr(v.Keypoints, reprSettings))
			else
				if v.Keypoints[1].Value == v.Keypoints[2].Value then
					return ("ColorSequence.new(%s)"):format(repr(v.Keypoints[1].Value, reprSettings))
				else
					return ("ColorSequence.new(%s, %s)"):format(
						repr(v.Keypoints[1].Value, reprSettings),
						repr(v.Keypoints[2].Value, reprSettings)
					)
				end
			end
		elseif typeof(v) == "ColorSequenceKeypoint" then
			return ("ColorSequenceKeypoint.new(%d, %s)"):format(v.Time, repr(v.Value, reprSettings))
		elseif typeof(v) == "DockWidgetPluginGuiInfo" then
			return ("DockWidgetPluginGuiInfo.new(%s, %s, %s, %s, %s, %s, %s)"):format(
				repr(v.InitialDockState, reprSettings),
				repr(v.InitialEnabled, reprSettings),
				repr(v.InitialEnabledShouldOverrideRestore, reprSettings),
				repr(v.FloatingXSize, reprSettings),
				repr(v.FloatingYSize, reprSettings),
				repr(v.MinWidth, reprSettings),
				repr(v.MinHeight, reprSettings)
			)
		elseif typeof(v) == "Enums" then
			return "Enums"
		elseif typeof(v) == "Enum" then
			return ("Enum.%s"):format(tostring(v))
		elseif typeof(v) == "EnumItem" then
			return ("Enum.%s.%s"):format(tostring(v.EnumType), v.Name)
		elseif typeof(v) == "Faces" then
			local s = {}
			for _, enumItem in pairs(Enum.NormalId:GetEnumItems()) do
				if v[enumItem.Name] then
					table.insert(s, repr(enumItem, reprSettings))
				end
			end
			return ("Faces.new(%s)"):format(table.concat(s, ", "))
		elseif typeof(v) == "NumberRange" then
			if v.Min == v.Max then
				return ("NumberRange.new(%d)"):format(v.Min)
			else
				return ("NumberRange.new(%d, %d)"):format(v.Min, v.Max)
			end
		elseif typeof(v) == "NumberSequence" then
			if #v.Keypoints > 2 then
				return ("NumberSequence.new(%s)"):format(repr(v.Keypoints, reprSettings))
			else
				if v.Keypoints[1].Value == v.Keypoints[2].Value then
					return ("NumberSequence.new(%d)"):format(v.Keypoints[1].Value)
				else
					return ("NumberSequence.new(%d, %d)"):format(v.Keypoints[1].Value, v.Keypoints[2].Value)
				end
			end
		elseif typeof(v) == "NumberSequenceKeypoint" then
			if v.Envelope ~= 0 then
				return ("NumberSequenceKeypoint.new(%d, %d, %d)"):format(v.Time, v.Value, v.Envelope)
			else
				return ("NumberSequenceKeypoint.new(%d, %d)"):format(v.Time, v.Value)
			end
		elseif typeof(v) == "PathWaypoint" then
			return ("PathWaypoint.new(%s, %s)"):format(
				repr(v.Position, reprSettings),
				repr(v.Action, reprSettings)
			)
		elseif typeof(v) == "PhysicalProperties" then
			return ("PhysicalProperties.new(%d, %d, %d, %d, %d)"):format(
				v.Density, v.Friction, v.Elasticity, v.FrictionWeight, v.ElasticityWeight
			)
		elseif typeof(v) == "Random" then
			return "<Random>"
		elseif typeof(v) == "Ray" then
			return ("Ray.new(%s, %s)"):format(
				repr(v.Origin, reprSettings),
				repr(v.Direction, reprSettings)
			)
		elseif typeof(v) == "RBXScriptConnection" then
			return "<RBXScriptConnection>"
		elseif typeof(v) == "RBXScriptSignal" then
			return "<RBXScriptSignal>"
		elseif typeof(v) == "Rect" then
			return ("Rect.new(%d, %d, %d, %d)"):format(
				v.Min.X, v.Min.Y, v.Max.X, v.Max.Y
			)
		elseif typeof(v) == "Region3" then
			local min = v.CFrame.Position + v.Size * -.5
			local max = v.CFrame.Position + v.Size * .5
			return ("Region3.new(%s, %s)"):format(
				repr(min, reprSettings),
				repr(max, reprSettings)
			)
		elseif typeof(v) == "Region3int16" then
			return ("Region3int16.new(%s, %s)"):format(
				repr(v.Min, reprSettings),
				repr(v.Max, reprSettings)
			)
		elseif typeof(v) == "TweenInfo" then
			return ("TweenInfo.new(%d, %s, %s, %d, %s, %d)"):format(
				v.Time, repr(v.EasingStyle, reprSettings), repr(v.EasingDirection, reprSettings),
				v.RepeatCount, repr(v.Reverses, reprSettings), v.DelayTime
			)
		elseif typeof(v) == "UDim" then
			return ("UDim.new(%d, %d)"):format(
				v.Scale, v.Offset
			)
		elseif typeof(v) == "UDim2" then
			return ("UDim2.new(%d, %d, %d, %d)"):format(
				v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset
			)
		elseif typeof(v) == "Vector2" then
			return ("Vector2.new(%d, %d)"):format(v.X, v.Y)
		elseif typeof(v) == "Vector2int16" then
			return ("Vector2int16.new(%d, %d)"):format(v.X, v.Y)
		elseif typeof(v) == "Vector3" then
			return ("Vector3.new(%d, %d, %d)"):format(v.X, v.Y, v.Z)
		elseif typeof(v) == "Vector3int16" then
			return ("Vector3int16.new(%d, %d, %d)"):format(v.X, v.Y, v.Z)
		elseif typeof(v) == "DateTime" then
			return ("DateTime.fromIsoDate(%q)"):format(v:ToIsoDate())
		else
			return "<Roblox:" .. typeof(v) .. ">"
		end
	else
		return "<" .. type(v) .. ">"
	end
end

local getsyncmodule = repr 

local a = game.ReplicatedStorage.Remotes.Events.GetEvents:InvokeServer()

-- data = getsyncmodule(a)

-- Universal Tab ------------------------------------------------------
local Universal = Window:Tab({
	Title = "Universal",
	Icon = "house"
})


-- Universal/WalkSpeed(Slider)
local currentSpeed = 16

local function applySpeed(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = currentSpeed
end

if player.Character then
	applySpeed(player.Character)
end

player.CharacterAdded:Connect(applySpeed)

Universal:Slider({
	Title = "WalkSpeed",

	Step = 1,

	Value = {
		Min = 16,
		Max = 100,
		Default = 16
	},

	Callback = function(value)
		currentSpeed = value
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end
})

-- Universal/JumpPower(Slider)
local currentJumpPower = 50

local function applyJumpPower(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.JumpPower = currentJumpPower
end

if player.Character then
	applyJumpPower(player.Character)
end

player.CharacterAdded:Connect(applyJumpPower)

Universal:Slider({
	Title = "JumpPower",

	Step = 1,

	Value = {
		Min = 50,
		Max = 500,
		Default = 50
	},

	Callback = function(value)
		currentJumpPower = value
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = value
		end
	end
})

-- Universal/Fly(Toggle)
local maxSpeed = 128
local flyEnabled = false
local flyAttachment, align, linear, flyConnection
local currentFlySpeed = 0

local function stopFly()
	flyEnabled = false
	if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
	if flyAttachment then flyAttachment.Parent = nil end
	if linear then linear.VectorVelocity = Vector3.zero end
	currentFlySpeed = 0
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

local function startFly(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = humanoid.RootPart
	if not rootPart then return end

	flyAttachment = Instance.new("Attachment")
	flyAttachment.Parent = rootPart

	align = Instance.new("AlignOrientation")
	align.Attachment0 = flyAttachment
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.RigidityEnabled = true
	align.Enabled = true
	align.Parent = flyAttachment

	linear = Instance.new("LinearVelocity")
	linear.Attachment0 = flyAttachment
	linear.ForceLimitsEnabled = false
	linear.Enabled = true
	linear.Parent = flyAttachment

	humanoid.PlatformStand = true
	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local camera = workspace.CurrentCamera

	flyConnection = RunService.Heartbeat:Connect(function(delta)
		if not flyEnabled then return end
		if not (character and character:IsDescendantOf(workspace)) then return end

		align.CFrame = camera.CFrame

		local up = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 1
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then up = -1 end

		local moveDir = humanoid.MoveDirection
		if up ~= 0 or moveDir ~= Vector3.zero then
			currentFlySpeed = math.min(currentFlySpeed + delta * maxSpeed / 4, maxSpeed)
			local look = camera.CFrame.LookVector
			local reference = CFrame.lookAlong(camera.CFrame.Position, Vector3.new(look.X, 0, look.Z), Vector3.yAxis)
			local controlVector = reference:VectorToObjectSpace(moveDir).Unit
			if controlVector ~= controlVector then controlVector = Vector3.zero end
			local worldMove = camera.CFrame:VectorToWorldSpace(controlVector)
			linear.VectorVelocity = (worldMove + Vector3.new(0, up, 0)) * currentFlySpeed
		else
			currentFlySpeed = math.max(currentFlySpeed - delta * maxSpeed / 2, math.min(humanoid.WalkSpeed, maxSpeed))
			linear.VectorVelocity = Vector3.zero
		end
	end)
end

player.CharacterAdded:Connect(function(character)
	if flyEnabled then startFly(character) end
end)

Universal:Toggle({
	Title = "Fly",
	Callback = function(state)
		flyEnabled = state
		if state then
			if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
				startFly(player.Character)
			end
		else
			stopFly()
		end
	end
})

-- Universal/NoClip(Toggle)
local noclipping = false

local function noClip(model, reset)
	if noclipping or reset then
		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				if reset then
					local initial = descendant:GetAttribute("_InitialCanCollide")
					if initial ~= nil then descendant.CanCollide = initial end
				else
					if not descendant:GetAttribute("_InitialCanCollide") then
						descendant:SetAttribute("_InitialCanCollide", descendant.CanCollide)
					end
					descendant.CanCollide = false
				end
			end
		end
	end
end

local function onCharacterAddedNoClip(character)
	if noclipping then noClip(character, false) end
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.StateChanged:Connect(function()
		noClip(character, not noclipping)
	end)
end

player.CharacterAdded:Connect(onCharacterAddedNoClip)
if player.Character then onCharacterAddedNoClip(player.Character) end

Universal:Toggle({
	Title = "NoClip",
	Callback = function(state)
		noclipping = state
		if player.Character then noClip(player.Character, not state) end
	end
})

-- Universal/AntiAFK(Toggle)
local vu = game:GetService("VirtualUser")
local afkEnabled = false
local afkConnection

local function startAntiAFK()
	vu:CaptureController()
	afkConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not afkEnabled then return end
		vu:ClickButton2(Vector2.new())
	end)
end

local function stopAntiAFK()
	if afkConnection then
		afkConnection:Disconnect()
		afkConnection = nil
	end
end

Universal:Toggle({
	Title = "Anti AFK",
	Callback = function(state)
		afkEnabled = state
		if state then
			startAntiAFK()
		else
			stopAntiAFK()
		end
	end
})

-- Universal/ESP(Toggle)
local espEnabled = false
local espObjects = {}

local function cleanupESP(player)
	local data = espObjects[player]
	if data then
		if data.connection then data.connection:Disconnect() end
		if data.billboard then data.billboard:Destroy() end
		if data.highlight then data.highlight:Destroy() end
		espObjects[player] = nil
	end
end

local function createESP(player)
	if player == game.Players.LocalPlayer then return end
	if espObjects[player] then return end

	local function attach()
		local char = player.Character
		if not char then return end
		local head = char:WaitForChild("Head", 5)
		if not head then return end

		-- Highlight (обводка)
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 0, 0) 
		highlight.OutlineTransparency = 0
		highlight.Adornee = char 
		highlight.Parent = char

		-- Billboard (имя + дистанция)
		local billboard = Instance.new("BillboardGui")
		billboard.Adornee = head
		billboard.Size = UDim2.new(0, 100, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = game:GetService("CoreGui")

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 1
		frame.Parent = billboard

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 14)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 12
		nameLabel.Text = player.Name
		nameLabel.Parent = frame

		local distLabel = Instance.new("TextLabel")
		distLabel.Size = UDim2.new(1, 0, 0, 14)
		distLabel.Position = UDim2.new(0, 0, 0, 14)
		distLabel.BackgroundTransparency = 1
		distLabel.TextColor3 = Color3.fromRGB(179, 179, 255)
		distLabel.Font = Enum.Font.Gotham
		distLabel.TextSize = 11
		distLabel.Parent = frame

		espObjects[player] = {
			billboard = billboard,
			highlight = highlight,
			connection = nil
		}

		local conn
		conn = game:GetService("RunService").RenderStepped:Connect(function()
			if not espEnabled then
				conn:Disconnect()
				return
			end
			if not player.Character or not player.Character:FindFirstChild("Head") then
				cleanupESP(player)
				return
			end
			local localChar = game.Players.LocalPlayer.Character
			if localChar and localChar:FindFirstChild("HumanoidRootPart") then
				local dist = (localChar.HumanoidRootPart.Position - player.Character.Head.Position).Magnitude
				distLabel.Text = math.floor(dist) .. " studs"
			end
		end)
		espObjects[player].connection = conn
	end

	if player.Character then
		attach()
	end
	player.CharacterAdded:Connect(function()
		if espEnabled then
			attach()
		end
	end)
end

local function enableESP()
	for _, plr in ipairs(game.Players:GetPlayers()) do
		createESP(plr)
	end
	game.Players.PlayerAdded:Connect(function(plr)
		if espEnabled then
			createESP(plr)
		end
	end)
	game.Players.PlayerRemoving:Connect(function(plr)
		cleanupESP(plr)
	end)
end

local function disableESP()
	for plr, _ in pairs(espObjects) do
		cleanupESP(plr)
	end
end

Universal:Toggle({
	Title = "ESP",
	Callback = function(state)
		espEnabled = state
		if state then
			enableESP()
		else
			disableESP()
		end
	end
})




-- Credits Tab ------------------------------------------------------
local Credits = Window:Tab({
	Title = "Credits",
	Icon = "info"
})

Credits:Paragraph({
	Title = "Developer",      
	Desc = "Made by " .. myName
})

Credits:Divider()



Credits:Button({
	Title = "Copy Roblox Username",
	Desc = robloxUsername,
	Callback = function()
		if setclipboard then
			setclipboard(robloxUsername)
			WindUI:Notify({
				Title = "Copied",
				Content = "Roblox username copied to clipboard!",
				Duration = 3
			})
		end
	end
})

Credits:Button({
	Title = "Copy Telegram",
	Desc = "@"..telegramUsername,
	Callback = function()
		if setclipboard then
			setclipboard("@"..telegramUsername)
			WindUI:Notify({
				Title = "Copied",
				Content = "Telegram username copied to clipboard!",
				Duration = 3
			})
		end
	end
})

Credits:Divider()

Credits:Paragraph({
	Title = "Thank you!",
	Desc = "Thanks for using " .. hubName .. " Hub ❤️"
})






-- MM2 Tab ------------------------------------------------------------
local MM2 = Window:Tab({
	Title = "MM2",
	Icon = "sword"
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetCurrentPlayerData = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("Gameplay"):WaitForChild("GetCurrentPlayerData")

local mm2_espEnabled = false
local mm2_espObjects = {}
local mm2_currentPlayerData = {}

local mm2_roleColors = {
	Murderer = Color3.fromRGB(255, 0, 0),
	Sheriff = Color3.fromRGB(0, 0, 255),
	Innocent = Color3.fromRGB(0, 255, 0)
}

local function mm2_fetchPlayerData()
	local success, data = pcall(function()
		return GetCurrentPlayerData:InvokeServer()
	end)
	if success and type(data) == "table" then
		mm2_currentPlayerData = data
	else
		mm2_currentPlayerData = {}
	end
end

local function mm2_getPlayerRole(plr)
	for _, info in ipairs(mm2_currentPlayerData) do
		local name = info.Name or info.Username or info.PlayerName or info.DisplayName
		if name and (name == plr.Name or name == plr.DisplayName) then
			return info.Role
		end
	end
	return nil
end

local function mm2_cleanupESP(plr)
	local data = mm2_espObjects[plr]
	if data then
		pcall(function() data.connection:Disconnect() end)
		pcall(function() data.highlight:Destroy() end)
		pcall(function() data.billboard:Destroy() end)
		mm2_espObjects[plr] = nil
	end
end

local function mm2_createESP(plr)
	if plr == player then return end
	if mm2_espObjects[plr] then return end

	local char = plr.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	local role = mm2_getPlayerRole(plr)
	local color = mm2_roleColors[role] or Color3.fromRGB(255, 255, 255)

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.Adornee = char
	highlight.Parent = char

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 150, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = game:GetService("CoreGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = billboard

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = color
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.Text = plr.Name .. (role and (" [" .. role .. "]") or "")
	nameLabel.Parent = frame

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, 0, 0, 14)
	distLabel.Position = UDim2.new(0, 0, 0, 14)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextSize = 11
	distLabel.Parent = frame

	mm2_espObjects[plr] = {
		highlight = highlight,
		billboard = billboard,
		connection = nil
	}

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not mm2_espEnabled then
			pcall(function() conn:Disconnect() end)
			return
		end
		if not plr.Character or not plr.Character:FindFirstChild("Head") then
			mm2_cleanupESP(plr)
			return
		end
		local localChar = player.Character
		if localChar and localChar:FindFirstChild("HumanoidRootPart") then
			local dist = (localChar.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude
			distLabel.Text = math.floor(dist) .. " studs"
		end
	end)
	mm2_espObjects[plr].connection = conn
end

local function mm2_refreshAllESP()
	for plr, _ in pairs(mm2_espObjects) do
		mm2_cleanupESP(plr)
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		mm2_createESP(plr)
	end
end

local function mm2_startAutoRefresh()
	task.spawn(function()
		while mm2_espEnabled do
			mm2_fetchPlayerData()
			if mm2_espEnabled then
				mm2_refreshAllESP()
			end
			task.wait(0.5)
		end
	end)
end

local function mm2_enableESP()
	mm2_fetchPlayerData()
	for _, plr in ipairs(Players:GetPlayers()) do
		mm2_createESP(plr)
	end
	Players.PlayerAdded:Connect(function(plr)
		if mm2_espEnabled then mm2_createESP(plr) end
	end)
	Players.PlayerRemoving:Connect(function(plr) mm2_cleanupESP(plr) end)
	mm2_startAutoRefresh()
	if #mm2_currentPlayerData > 0 then
		print("===== MM2 PlayerData =====")
		print(getsyncmodule(mm2_currentPlayerData))
	end
end

local function mm2_disableESP()
	for plr, _ in pairs(mm2_espObjects) do mm2_cleanupESP(plr) end
end

MM2:Toggle({
	Title = "MM2 ESP",
	Callback = function(state)
		mm2_espEnabled = state
		if state then mm2_enableESP() else mm2_disableESP() end
	end
})

-- +1 Speed Keyboard Escape Tab ---------------------------------------
local KeyboardEscape = Window:Tab({
	Title = "+1 Speed Keyboard Escape",
	Icon = "keyboard"
})

KeyboardEscape:Toggle({
	Title = "Show Special Key",
	Callback = function(state)
		-- заготовка
	end
})


-- Other --------------------------------------------------------------
Window:SelectTab(Universal)

print("✅" .. hubName .. " Hub Loaded: version " .. hubVersion)
