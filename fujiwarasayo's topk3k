-- Topk3k Client Edition
-- fujiwarasayo's T0PK3K GUI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Helper Functions
local function safeParent(gui)
    local ok = pcall(function()
        gui.Parent = CoreGui
    end)
    if not ok or not gui.Parent then
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        gui.Parent = pg
    end
end

-- Create Topk3k GUI
local Topk3kGui = Instance.new("ScreenGui")
Topk3kGui.Name = "Topk3kGui"
Topk3kGui.ResetOnSpawn = false
safeParent(Topk3kGui)

local Topk3kBase = Instance.new("Frame")
Topk3kBase.Name = "Base"
Topk3kBase.Size = UDim2.new(0, 500, 0, 400)
Topk3kBase.Position = UDim2.new(0.5, -250, 0.5, -200)
Topk3kBase.BackgroundColor3 = Color3.fromRGB(14, 23, 29)
Topk3kBase.BorderColor3 = Color3.fromRGB(4, 7, 9)
Topk3kBase.BorderSizePixel = 2
Topk3kBase.Active = true
Topk3kBase.Visible = true
Topk3kBase.Parent = Topk3kGui

-- Top Bar
local Top = Instance.new("Frame")
Top.Name = "Top"
Top.Size = UDim2.new(1, -20, 0, 30)
Top.Position = UDim2.new(0, 10, 0, 10)
Top.BackgroundColor3 = Color3.fromRGB(7, 11, 15)
Top.BackgroundTransparency = 0.5
Top.BorderColor3 = Color3.fromRGB(62, 62, 62)
Top.Parent = Topk3kBase

local First = Instance.new("TextLabel")
First.Name = "First"
First.Size = UDim2.new(0.7, 0, 1, 0)
First.BackgroundTransparency = 1
First.Font = Enum.Font.SourceSansBold
First.TextSize = 16
First.Text = "  fujiwarasayo's T0PK3K"
First.TextColor3 = Color3.fromRGB(184, 7, 54)
First.TextStrokeTransparency = 0
First.TextXAlignment = Enum.TextXAlignment.Left
First.Parent = Top

local Second = Instance.new("TextLabel")
Second.Name = "Second"
Second.Size = UDim2.new(0.3, 0, 1, 0)
Second.Position = UDim2.new(0.7, 0, 0, 0)
Second.BackgroundTransparency = 1
Second.Font = Enum.Font.SourceSansBold
Second.TextSize = 16
Second.Text = "Client Edition"
Second.TextColor3 = Color3.fromRGB(184, 7, 54)
Second.TextStrokeTransparency = 0
Second.TextXAlignment = Enum.TextXAlignment.Right
Second.Parent = Top

local Exit = Instance.new("TextButton")
Exit.Name = "Exit"
Exit.Size = UDim2.new(0, 25, 0, 25)
Exit.Position = UDim2.new(1, -26, 0.5, -12.5)
Exit.BackgroundColor3 = Color3.fromRGB(184, 7, 54)
Exit.BorderSizePixel = 0
Exit.Font = Enum.Font.SourceSansBold
Exit.TextSize = 14
Exit.Text = "X"
Exit.TextColor3 = Color3.new(1, 1, 1)
Exit.Parent = Top

Exit.MouseButton1Click:Connect(function()
    Topk3kBase.Visible = false
end)

-- Dragging
local dragging = false
local dragStart
local startPos

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Topk3kBase.Position
    end
end)

Top.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Topk3kBase.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Main Container
local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(1, -20, 1, -60)
MainContainer.Position = UDim2.new(0, 10, 0, 50)
MainContainer.BackgroundColor3 = Color3.fromRGB(7, 11, 15)
MainContainer.BackgroundTransparency = 0.5
MainContainer.BorderColor3 = Color3.fromRGB(62, 62, 62)
MainContainer.ScrollBarThickness = 5
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainContainer.Parent = Topk3kBase

-- Layout for main container
local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding = UDim.new(0, 8)
MainLayout.Parent = MainContainer

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 8)
Padding.PaddingRight = UDim.new(0, 8)
Padding.PaddingTop = UDim.new(0, 8)
Padding.PaddingBottom = UDim.new(0, 8)
Padding.Parent = MainContainer

-- Helper functions for Topk3k UI
local function MakeTopk3kLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.Text = text
    label.TextColor3 = Color3.fromRGB(184, 7, 54)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = MainContainer
    return label
end

local function MakeTopk3kRowContainer()
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = MainContainer
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container
    
    return container
end

local function MakeTopk3kTextBox(widthPercent, placeholder)
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(widthPercent, -4, 0, 28)
    textbox.BackgroundColor3 = Color3.fromRGB(5, 8, 11)
    textbox.BorderColor3 = Color3.fromRGB(27, 42, 53)
    textbox.Font = Enum.Font.SourceSans
    textbox.TextSize = 14
    textbox.Text = placeholder
    textbox.PlaceholderText = placeholder
    textbox.TextColor3 = Color3.fromRGB(199, 199, 199)
    textbox.ClearTextOnFocus = false
    return textbox
end

local function MakeTopk3kButton(widthPercent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(widthPercent, -4, 0, 28)
    button.BackgroundColor3 = Color3.fromRGB(15, 23, 30)
    button.BorderColor3 = Color3.fromRGB(27, 42, 53)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Text = text
    button.TextColor3 = Color3.fromRGB(199, 199, 199)
    button.TextStrokeTransparency = 0.5
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Movement Section
MakeTopk3kLabel("[ Movement ]")

-- WalkSpeed Row
local wsRow = MakeTopk3kRowContainer()
local wsInput = MakeTopk3kTextBox(0.25, "16")
wsInput.Parent = wsRow
local wsButton = MakeTopk3kButton(0.75, "Set WalkSpeed", function()
    local val = tonumber(wsInput.Text)
    if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)
wsButton.Parent = wsRow

-- JumpPower Row
local jpRow = MakeTopk3kRowContainer()
local jpInput = MakeTopk3kTextBox(0.25, "50")
jpInput.Parent = jpRow
local jpButton = MakeTopk3kButton(0.75, "Set JumpPower", function()
    local val = tonumber(jpInput.Text)
    if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)
jpButton.Parent = jpRow

-- HipHeight Row
local hhRow = MakeTopk3kRowContainer()
local hhInput = MakeTopk3kTextBox(0.25, "0")
hhInput.Parent = hhRow
local hhButton = MakeTopk3kButton(0.75, "Set HipHeight", function()
    local val = tonumber(hhInput.Text)
    if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.HipHeight = val
    end
end)
hhButton.Parent = hhRow

-- Quick Actions Row
local quickRow = MakeTopk3kRowContainer()
local sitButton = MakeTopk3kButton(0.33, "Sit", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Sit = true
    end
end)
sitButton.Parent = quickRow

local jumpButton = MakeTopk3kButton(0.33, "Jump", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Jump = true
    end
end)
jumpButton.Parent = quickRow

local platformButton = MakeTopk3kButton(0.33, "Platform Stand", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = not LocalPlayer.Character.Humanoid.PlatformStand
    end
end)
platformButton.Parent = quickRow

-- Character Visual Section
MakeTopk3kLabel("[ Character Visual ]")

-- Visibility Row
local visRow = MakeTopk3kRowContainer()
local invisButton = MakeTopk3kButton(0.5, "Invisible", function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 1
            end
            if part:IsA("Decal") then
                part.Transparency = 1
            end
        end
    end
end)
invisButton.Parent = visRow

local visButton = MakeTopk3kButton(0.5, "Visible", function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            elseif part:IsA("MeshPart") then
                part.Transparency = 0
            end
            if part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end
end)
visButton.Parent = visRow

-- Head Size Row
local headRow = MakeTopk3kRowContainer()
local bigHeadButton = MakeTopk3kButton(0.33, "Big Head", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head:FindFirstChild("Mesh") then
        LocalPlayer.Character.Head.Mesh.Scale = Vector3.new(5, 5, 5)
    end
end)
bigHeadButton.Parent = headRow

local normalHeadButton = MakeTopk3kButton(0.33, "Normal Head", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head:FindFirstChild("Mesh") then
        LocalPlayer.Character.Head.Mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    end
end)
normalHeadButton.Parent = headRow

local tinyHeadButton = MakeTopk3kButton(0.33, "Tiny Head", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head:FindFirstChild("Mesh") then
        LocalPlayer.Character.Head.Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
    end
end)
tinyHeadButton.Parent = headRow

-- Color and Material Section
MakeTopk3kLabel("[ Color & Material ]")

local colorRow = MakeTopk3kRowContainer()
local colorInput = MakeTopk3kTextBox(0.25, "Bright red")
colorInput.Parent = colorRow
local colorButton = MakeTopk3kButton(0.75, "Set Color", function()
    if LocalPlayer.Character then
        local color = BrickColor.new(colorInput.Text)
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.BrickColor = color
            end
        end
    end
end)
colorButton.Parent = colorRow

local matRow = MakeTopk3kRowContainer()
local matInput = MakeTopk3kTextBox(0.25, "Neon")
matInput.Parent = matRow
local matButton = MakeTopk3kButton(0.75, "Set Material", function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function()
                    part.Material = Enum.Material[matInput.Text]
                end)
            end
        end
    end
end)
matButton.Parent = matRow

-- Effects Section
MakeTopk3kLabel("[ Effects ]")

local effectsRow1 = MakeTopk3kRowContainer()
local fireButton = MakeTopk3kButton(0.33, "Fire", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Instance.new("Fire", LocalPlayer.Character.HumanoidRootPart)
    end
end)
fireButton.Parent = effectsRow1

local sparklesButton = MakeTopk3kButton(0.33, "Sparkles", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Instance.new("Sparkles", LocalPlayer.Character.HumanoidRootPart)
    end
end)
sparklesButton.Parent = effectsRow1

local smokeButton = MakeTopk3kButton(0.33, "Smoke", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Instance.new("Smoke", LocalPlayer.Character.HumanoidRootPart)
    end
end)
smokeButton.Parent = effectsRow1

local effectsRow2 = MakeTopk3kRowContainer()
local lightButton = MakeTopk3kButton(0.33, "PointLight", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local light = Instance.new("PointLight", LocalPlayer.Character.HumanoidRootPart)
        light.Brightness = 5
        light.Range = 20
    end
end)
lightButton.Parent = effectsRow2

local highlightButton = MakeTopk3kButton(0.33, "Highlight", function()
    if LocalPlayer.Character then
        local highlight = Instance.new("Highlight", LocalPlayer.Character)
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
end)
highlightButton.Parent = effectsRow2

local removeEffectsButton = MakeTopk3kButton(0.33, "Remove Effects", function()
    if LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
            if obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Smoke") or obj:IsA("PointLight") or obj:IsA("ParticleEmitter") or obj:IsA("Highlight") then
                obj:Destroy()
            end
        end
    end
end)
removeEffectsButton.Parent = effectsRow2

-- Utility Section
MakeTopk3kLabel("[ Utility ]")

local utilRow1 = MakeTopk3kRowContainer()
local rejoinButton = MakeTopk3kButton(0.5, "Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)
rejoinButton.Parent = utilRow1

local copyJobButton = MakeTopk3kButton(0.5, "Copy JobId", function()
    setclipboard(game.JobId)
end)
copyJobButton.Parent = utilRow1

local utilRow2 = MakeTopk3kRowContainer()
local copyUserIdButton = MakeTopk3kButton(0.5, "Copy User ID", function()
    setclipboard(tostring(LocalPlayer.UserId))
end)
copyUserIdButton.Parent = utilRow2

local removeToolsButton = MakeTopk3kButton(0.5, "Remove Tools", function()
    if LocalPlayer.Backpack then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            tool:Destroy()
        end
    end
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
            end
        end
    end
end)
removeToolsButton.Parent = utilRow2

-- Chat Section
MakeTopk3kLabel("[ Chat ]")

local chatRow = MakeTopk3kRowContainer()
local chatInput = MakeTopk3kTextBox(0.5, "Message")
chatInput.Parent = chatRow
local chatButton = MakeTopk3kButton(0.5, "Chat", function()
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(chatInput.Text, "All")
end)
chatButton.Parent = chatRow

-- Public API
return {
    Show = function()
        Topk3kBase.Visible = true
    end,
    Hide = function()
        Topk3kBase.Visible = false
    end,
    Toggle = function()
        Topk3kBase.Visible = not Topk3kBase.Visible
    end,
    IsVisible = function()
        return Topk3kBase.Visible
    end,
    Destroy = function()
        Topk3kGui:Destroy()
    end
}
