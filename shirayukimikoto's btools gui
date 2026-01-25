-- shirayukimikoto's BTools GUI
-- Features: Delete, Clone, Move, and Undo tools

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local COLOR_PRIMARY = Color3.fromRGB(45, 45, 60)
local COLOR_BUTTON = Color3.fromRGB(60, 120, 215)
local COLOR_DANGER = Color3.fromRGB(200, 60, 60)
local COLOR_SUCCESS = Color3.fromRGB(60, 180, 90)
local COLOR_TEXT = Color3.new(1, 1, 1)

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

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "shirayukimikoto's BTools GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
safeParent(screenGui)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = COLOR_PRIMARY
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = COLOR_TEXT
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Text = "🔧 BTools"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = COLOR_DANGER
closeButton.BorderSizePixel = 0
closeButton.TextColor3 = COLOR_TEXT
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Text = "✕"
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Dragging Functionality
local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Content Area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -55)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = content

-- Undo Stack
local undoStack = {}

local function pushUndo(entry)
    table.insert(undoStack, entry)
end

local function popUndo()
    local entry = table.remove(undoStack)
    if not entry then return end
    
    if entry.action == "delete" then
        if entry.part and entry.parent then
            pcall(function()
                entry.part.Parent = entry.parent
                if entry.part:IsA("BasePart") and entry.canCollide ~= nil then
                    entry.part.CanCollide = entry.canCollide
                end
            end)
        end
    elseif entry.action == "clone" then
        if entry.clone and entry.clone.Parent then
            pcall(function()
                entry.clone:Destroy()
            end)
        end
    elseif entry.action == "move" then
        if entry.part and entry.prevCFrame then
            pcall(function()
                entry.part.CFrame = entry.prevCFrame
            end)
        end
    end
end

-- UI Element Creators
local function MakeButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color or COLOR_BUTTON
    btn.TextColor3 = COLOR_TEXT
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    return btn
end

local function MakeLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COLOR_TEXT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    return lbl
end

-- Section: Tool Inventory
local toolsLabel = MakeLabel("📦 Tool Inventory")
toolsLabel.Parent = content

local giveToolsBtn = MakeButton("Give All BTools", COLOR_SUCCESS)
giveToolsBtn.Parent = content

local btoolsInitialized = {}

giveToolsBtn.MouseButton1Click:Connect(function()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    
    local function makeTool(name)
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == name then
                t:Destroy()
            end
        end
        
        local tool = Instance.new("Tool")
        tool.Name = name
        tool.RequiresHandle = false
        tool.Parent = backpack
        return tool
    end
    
    local deleteTool = makeTool("🗑️ Delete")
    local cloneTool = makeTool("📋 Clone")
    local undoTool = makeTool("↩️ Undo")
    local moveTool = makeTool("✋ Move")
    
    -- Delete Tool
    if not btoolsInitialized["Delete"] then
        btoolsInitialized["Delete"] = true
        deleteTool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target and target:IsA("BasePart") and target.Parent ~= workspace.Terrain then
                pushUndo({
                    action = "delete",
                    part = target,
                    parent = target.Parent,
                    canCollide = target.CanCollide
                })
                target.Parent = nil
            end
        end)
    end
    
    -- Clone Tool
    if not btoolsInitialized["Clone"] then
        btoolsInitialized["Clone"] = true
        cloneTool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target and target:IsA("BasePart") then
                local ok, clone = pcall(function()
                    return target:Clone()
                end)
                
                if ok and clone then
                    local parent = target.Parent
                    if parent then
                        clone.Parent = parent
                    else
                        clone.Parent = workspace
                    end
                    
                    if clone:IsA("BasePart") then
                        clone.CFrame = clone.CFrame + Vector3.new(2, 0, 2)
                    end
                    
                    pushUndo({
                        action = "clone",
                        clone = clone
                    })
                end
            end
        end)
    end
    
    -- Undo Tool
    if not btoolsInitialized["Undo"] then
        btoolsInitialized["Undo"] = true
        undoTool.Activated:Connect(function()
            popUndo()
        end)
    end
    
    -- Move Tool
    if not btoolsInitialized["Move"] then
        btoolsInitialized["Move"] = true
        
        local moveConn
        local downConn
        local upConn
        local selectedPart
        local prevCFrame
        
        moveTool.Equipped:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            
            downConn = mouse.Button1Down:Connect(function()
                local target = mouse.Target
                if target and target:IsA("BasePart") and target.Parent ~= workspace.Terrain then
                    selectedPart = target
                    prevCFrame = selectedPart.CFrame
                    pushUndo({
                        action = "move",
                        part = selectedPart,
                        prevCFrame = prevCFrame
                    })
                    selectedPart.CanCollide = false
                    
                    moveConn = RunService.RenderStepped:Connect(function()
                        if selectedPart and selectedPart.Parent then
                            local hit = mouse.Hit
                            if hit then
                                local pos = hit.Position + Vector3.new(0, selectedPart.Size.Y / 2, 0)
                                selectedPart.CFrame = CFrame.new(pos)
                            end
                        end
                    end)
                end
            end)
            
            upConn = mouse.Button1Up:Connect(function()
                if moveConn then
                    moveConn:Disconnect()
                    moveConn = nil
                end
                if selectedPart then
                    selectedPart.CanCollide = true
                    selectedPart = nil
                end
            end)
        end)
        
        moveTool.Unequipped:Connect(function()
            if moveConn then
                moveConn:Disconnect()
                moveConn = nil
            end
            if downConn then
                downConn:Disconnect()
                downConn = nil
            end
            if upConn then
                upConn:Disconnect()
                upConn = nil
            end
            if selectedPart then
                selectedPart.CanCollide = true
                selectedPart = nil
            end
        end)
    end
end)

-- Section: Quick Delete
local quickLabel = MakeLabel("⚡ Quick Actions")
quickLabel.Parent = content

local localDeleteBtn = MakeButton("Toggle Click-Delete Mode", COLOR_BUTTON)
localDeleteBtn.Parent = content

local localDeleteConn
local deleteMode = false

localDeleteBtn.MouseButton1Click:Connect(function()
    if localDeleteConn then
        localDeleteConn:Disconnect()
        localDeleteConn = nil
        deleteMode = false
        localDeleteBtn.Text = "Toggle Click-Delete Mode"
        localDeleteBtn.BackgroundColor3 = COLOR_BUTTON
        return
    end
    
    deleteMode = true
    localDeleteBtn.Text = "🔴 Click-Delete ACTIVE"
    localDeleteBtn.BackgroundColor3 = COLOR_DANGER
    localDeleteConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target and target:IsA("BasePart") and target.Parent ~= workspace.Terrain then
                pushUndo({
                    action = "delete",
                    part = target,
                    parent = target.Parent,
                    canCollide = target.CanCollide
                })
                target.Parent = nil
            end
        end
    end)
end)

local undoLastBtn = MakeButton("Undo Last Action", COLOR_SUCCESS)
undoLastBtn.Parent = content

undoLastBtn.MouseButton1Click:Connect(function()
    popUndo()
end)

-- Section: Info
local infoLabel = MakeLabel("ℹ️ How to Use")
infoLabel.Parent = content

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 80)
infoText.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
infoText.BorderSizePixel = 0
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Text = [[
• Give Tools: Adds Delete, Clone, Move, and Undo tools to inventory
• Click-Delete: Instantly delete parts by clicking
• Undo: Reverses your last action
• All actions are reversible!
]]
infoText.Parent = content

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoText

local infoPadding = Instance.new("UIPadding")
infoPadding.PaddingLeft = UDim.new(0, 8)
infoPadding.PaddingTop = UDim.new(0, 8)
infoPadding.PaddingRight = UDim.new(0, 8)
infoPadding.Parent = infoText

print("✅ BTools GUI loaded successfully!")
