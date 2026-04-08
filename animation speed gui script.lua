-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Configuration Variables
local animationSpeed = 1
local isSpeedEnabled = false
local animatorConnection = nil

-- || GUI CREATION ||
-- We create the entire GUI via script so you don't have to build it.

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationSpeedGui"
screenGui.ResetOnSpawn = false -- This makes it stay after death
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 130)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -65) -- Center screen initially
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true -- Required for dragging
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title Label (Top Bar for dragging)
local title = Instance.new("TextLabel")
title.Name = "TitleBar"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Animation Speed"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Speed TextBox
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(1, -20, 0, 35)
speedInput.Position = UDim2.new(0, 10, 0, 40)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.Text = "1"
speedInput.PlaceholderText = "Enter Speed"
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 14
speedInput.Parent = mainFrame
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = speedInput

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(1, -20, 0, 35)
toggleBtn.Position = UDim2.new(0, 10, 0, 85)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Red when OFF
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = toggleBtn

-- || DRAGGING LOGIC ||
local dragging = false
local dragInput
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- || ANIMATION LOGIC ||

local function getAnimator()
	local character = player.Character
	if not character then return nil end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return nil end
	
	-- Check for Animator directly
	local animator = humanoid:FindFirstChild("Animator")
	if animator then return animator end
	
	-- Sometimes Animator is created late, try to wait for it briefly
	animator = humanoid:WaitForChild("Animator", 1)
	return animator
end

local function updateAnimationSpeed(speedValue)
	local animator = getAnimator()
	if not animator then return end
	
	-- Get all playing animation tracks and set their speed
	for _, track in pairs(animator:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(speedValue)
	end
end

-- Function to hook into the Animator to change speed on NEW animations
local function onAnimatorCreated(animator)
	if animatorConnection then
		animatorConnection:Disconnect()
	end
	
	-- When a new animation plays, immediately set its speed if toggle is ON
	animatorConnection = animator.AnimationPlayed:Connect(function(track)
		if isSpeedEnabled then
			track:AdjustSpeed(animationSpeed)
		end
	end)
end

-- Manage Character Respawning
local function onCharacterAdded(character)
	-- Wait for the Humanoid and Animator to exist
	task.defer(function()
		local humanoid = character:WaitForChild("Humanoid")
		local animator = humanoid:WaitForChild("Animator")
		
		-- Hook the animator
		onAnimatorCreated(animator)
		
		-- If speed is already on, apply it immediately to idle/walk animations that might start
		if isSpeedEnabled then
			-- We run this in a loop briefly to catch the idle animation loading in
			for i = 1, 5 do
				task.wait(0.5)
				updateAnimationSpeed(animationSpeed)
			end
		end
	end)
end

-- Listen for character spawn
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

-- || UI INTERACTION ||

-- Speed Input Handling
speedInput.FocusLost:Connect(function(enterPressed)
	local num = tonumber(speedInput.Text)
	if num then
		-- Clamp speed (Optional: remove if you want negative speeds)
		animationSpeed = num
		if isSpeedEnabled then
			updateAnimationSpeed(animationSpeed)
		end
	else
		-- Reset to valid number if input is bad
		speedInput.Text = tostring(animationSpeed)
	end
end)

-- Toggle Button Handling
toggleBtn.MouseButton1Click:Connect(function()
	isSpeedEnabled = not isSpeedEnabled
	
	if isSpeedEnabled then
		toggleBtn.Text = "ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- Green
		updateAnimationSpeed(animationSpeed)
	else
		toggleBtn.Text = "OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Red
		-- Reset speed to normal
		updateAnimationSpeed(1)
	end
end)
