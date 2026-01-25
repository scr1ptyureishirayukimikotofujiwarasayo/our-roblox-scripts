-- shirayukimikoto_movement_tools.lua
-- Standalone movement features: Fly, Noclip, InfiniteJump, LoopWalkSpeed
-- Expects: MakeToggle, content, LocalPlayer, RunService, UserInputService

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Reuse original colors
local COLOR_BUTTON = Color3.fromRGB(0, 120, 215)
local COLOR_TEXT = Color3.new(1, 1, 1)

-- UI Helpers (minimal, matching main menu style)
local function MakeLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = COLOR_TEXT
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = content
	return lbl
end

local function MakeTextBox(text)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(1, 0, 0, 32)
	tb.BackgroundColor3 = COLOR_BUTTON
	tb.TextColor3 = COLOR_TEXT
	tb.BorderSizePixel = 0
	tb.Text = text
	tb.ClearTextOnFocus = false
	tb.Font = Enum.Font.Gotham
	tb.TextSize = 14
	tb.Parent = content
	return tb
end

-- ===== MOVEMENT FEATURES =====
MakeLabel("Movement")

-- Fly Feature
local flyConn
local flyGyro
local flyVel
local flySpeed = 50

local function ReinitFly()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end
	end

	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyGyro.P = 9e4
	flyGyro.CFrame = hrp.CFrame
	flyGyro.Parent = hrp

	flyVel = Instance.new("BodyVelocity")
	flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyVel.Velocity = Vector3.new(0, 0, 0)
	flyVel.Parent = hrp

	if flyConn then
		flyConn:Disconnect()
	end

	flyConn = RunService.RenderStepped:Connect(function()
		if not flyGyro or not flyVel or not hrp or not hrp.Parent then
			return
		end

		local cam = workspace.CurrentCamera
		if not cam then return end

		local cf = cam.CFrame
		flyGyro.CFrame = cf

		local dir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			dir = dir + cf.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			dir = dir - cf.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			dir = dir - cf.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			dir = dir + cf.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			dir = dir + cf.UpVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			dir = dir - cf.UpVector
		end

		if dir.Magnitude > 0 then
			flyVel.Velocity = dir.Unit * flySpeed
		else
			flyVel.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

MakeToggle(content, "Fly", function(on)
	if on then
		ReinitFly()
	else
		if flyConn then
			flyConn:Disconnect()
			flyConn = nil
		end
		if flyGyro then
			flyGyro:Destroy()
			flyGyro = nil
		end
		if flyVel then
			flyVel:Destroy()
			flyVel = nil
		end
	end
end)

-- Noclip Feature
local noclipConn
MakeToggle(content, "Noclip", function(on)
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end

	if on then
		noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if not char then return end

			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end)

-- Infinite Jump Feature
local infJumpConn
MakeToggle(content, "InfiniteJump", function(on)
	if infJumpConn then
		infJumpConn:Disconnect()
		infJumpConn = nil
	end

	if on then
		infJumpConn = UserInputService.JumpRequest:Connect(function()
			local char = LocalPlayer.Character
			if not char then return end

			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end
end)

-- WalkSpeed Feature
MakeLabel("Loop WalkSpeed")

local loopWsEnabled = false
local targetWalkSpeed = 16
local loopWsConn
local originalWalkSpeed

local wsBox = MakeTextBox("WalkSpeed: 16")
wsBox.FocusLost:Connect(function()
	local val = tonumber(wsBox.Text:match("%d+"))
	if val and val > 0 then
		targetWalkSpeed = val
		wsBox.Text = "WalkSpeed: " .. targetWalkSpeed
	else
		wsBox.Text = "WalkSpeed: " .. targetWalkSpeed
	end
end)

MakeToggle(content, "LoopWalkSpeed", function(on)
	loopWsEnabled = on

	if loopWsConn then
		loopWsConn:Disconnect()
		loopWsConn = nil
	end

	local function apply()
		local char = LocalPlayer.Character
		if not char then return end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			if on and originalWalkSpeed == nil then
				originalWalkSpeed = hum.WalkSpeed
			end

			if on then
				hum.WalkSpeed = targetWalkSpeed
			else
				if originalWalkSpeed ~= nil then
					hum.WalkSpeed = originalWalkSpeed
				else
					hum.WalkSpeed = 16
				end
			end
		end
	end

	if on then
		apply()
		loopWsConn = RunService.Heartbeat:Connect(apply)
	else
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and originalWalkSpeed ~= nil then
				hum.WalkSpeed = originalWalkSpeed
			end
		end
		originalWalkSpeed = nil
	end
end)

print("✅ Movement tools loaded!")
