--[[
    CUSTOM MOVEMENT UI (LocalScript)
    Place in: StarterPlayer > StarterPlayerScripts
    
    WARNING: Using this in public servers may get you banned.
    Use only for testing or in games that allow it.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration
local START_SPEED = 16
local GUI_NAME = "MovementController"
local GUI_COLOR = Color3.fromRGB(40, 40, 40)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local ACCENT_COLOR = Color3.fromRGB(0, 150, 255)

-- State Variables
local isEnabled = false
local currentSpeed = START_SPEED
local isMinimized = false
local dragged = false
local dragInput = nil
local dragStart = nil
local startPos = nil

-- // 1. CREATE GUI ELEMENTS //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.BackgroundColor3 = GUI_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = ACCENT_COLOR
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Movement UI"
Title.TextColor3 = TEXT_COLOR
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Minimize Button (Built into Header logic, but visual indicator here)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = TEXT_COLOR
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = Header

-- Content Frame (Holds inputs, gets hidden on minimize)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- TextBox (Speed Input)
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 10)
SpeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Text = tostring(START_SPEED)
SpeedBox.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
SpeedBox.PlaceholderText = "Speed"
SpeedBox.Parent = ContentFrame

-- Validate Input
SpeedBox.FocusLost:Connect(function(enterPressed)
    local num = tonumber(SpeedBox.Text)
    if num then
        currentSpeed = math.clamp(num, 0, 500) -- Cap at 500 to prevent crashes
        SpeedBox.Text = tostring(currentSpeed)
        if isEnabled then
            applySpeed()
        end
    else
        SpeedBox.Text = tostring(currentSpeed)
    end
end)

-- Toggle Button (Enable/Disable)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red for OFF
ToggleBtn.Text = "DISABLED"
ToggleBtn.TextColor3 = TEXT_COLOR
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = ContentFrame

-- // 2. LOGIC FUNCTIONS //

local function applySpeed()
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if isEnabled then
            humanoid.WalkSpeed = currentSpeed
            humanoid.JumpPower = 35 + (currentSpeed * 0.5) -- Scale jump slightly with speed
            -- Note: SwimSpeed is usually tied to WalkSpeed on client, 
            -- but specific swimming states vary by game.
        else
            -- Reset to default
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end

local function updateToggleVisuals()
    if isEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Green for ON
        ToggleBtn.Text = "ENABLED"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red for OFF
        ToggleBtn.Text = "DISABLED"
        -- Revert speed immediately if turning off
        applySpeed()
    end
end

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 200, 0, 30)
        ContentFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, 150)
        ContentFrame.Visible = true
        MinimizeBtn.Text = "−"
    end
end

-- // 3. CONNECTIONS & EVENTS //

-- Toggle Button Click
ToggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateToggleVisuals()
    applySpeed()
end)

-- Minimize Button Click
MinimizeBtn.MouseButton1Click:Connect(function()
    toggleMinimize()
end)

-- Character Added (Respawn Handling)
Player.CharacterAdded:Connect(function()
    -- Wait for Humanoid to exist
    local character = Player.Character
    if character then
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid and isEnabled then
            applySpeed()
        end
    end
end)

-- Initialize on load (if character exists)
task.spawn(function()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Ensure defaults on start
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end)

-- // 4. DRAGGABLE LOGIC //

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragged = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragged = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragged then
        updateInput(input)
    end
end)

-- Prevent GUI from blocking clicks on 3D objects (Optional, keeps it interactive)
ScreenGui.DisplayOrder = 100
