-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    WindowTitle = "shirayukimikoto's mod menu",
    Colors = {
        Primary = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 40),
        Accent = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Danger = Color3.fromRGB(237, 66, 69),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 190)
    },
    Sizes = {
        WindowWidth = 380,
        WindowHeight = 520,
        HeaderHeight = 45,
        ButtonHeight = 36,
        Spacing = 8,
        CornerRadius = 8
    }
}

-- Initialize shared globals
_G.shirayukimikoto_savedPosition = _G.shirayukimikoto_savedPosition or nil
_G.shirayukimikoto_antiTeleportEnabled = _G.shirayukimikoto_antiTeleportEnabled or false

-- Utility Functions
local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or CONFIG.Sizes.CornerRadius)
    return corner
end

local function createPadding(all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all)
    padding.PaddingBottom = UDim.new(0, all)
    padding.PaddingLeft = UDim.new(0, all)
    padding.PaddingRight = UDim.new(0, all)
    return padding
end

local function safeParent(gui)
    local success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShirayukiModMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
safeParent(screenGui)

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, CONFIG.Sizes.WindowWidth, 0, CONFIG.Sizes.WindowHeight)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.BackgroundColor3 = CONFIG.Colors.Primary
mainContainer.BorderSizePixel = 0
mainContainer.Active = true
mainContainer.Parent = screenGui

createCorner(CONFIG.Sizes.CornerRadius).Parent = mainContainer

-- Drop shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = 0
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainContainer

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.HeaderHeight)
header.BackgroundColor3 = CONFIG.Colors.Secondary
header.BorderSizePixel = 0
header.Parent = mainContainer

createCorner(CONFIG.Sizes.CornerRadius).Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Name = "Title"
headerTitle.Size = UDim2.new(1, -100, 1, 0)
headerTitle.Position = UDim2.new(0, 15, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = CONFIG.WindowTitle
headerTitle.TextColor3 = CONFIG.Colors.Text
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(0, 0.5)
closeBtn.BackgroundColor3 = CONFIG.Colors.Danger
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = CONFIG.Colors.Text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = header

createCorner(6).Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainContainer.Visible = false
end)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -80, 0.5, 0)
minimizeBtn.AnchorPoint = Vector2.new(0, 0.5)
minimizeBtn.BackgroundColor3 = CONFIG.Colors.Accent
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = CONFIG.Colors.Text
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = header

createCorner(6).Parent = minimizeBtn

local isMinimized = false
local originalSize = mainContainer.Size

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, CONFIG.Sizes.WindowWidth, 0, CONFIG.Sizes.HeaderHeight) or originalSize
    
    TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Size = targetSize
    }):Play()
end)

-- Dragging functionality
local dragging = false
local dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainContainer.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Content Container
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Name = "Content"
contentContainer.Size = UDim2.new(1, -20, 1, -CONFIG.Sizes.HeaderHeight - 20)
contentContainer.Position = UDim2.new(0, 10, 0, CONFIG.Sizes.HeaderHeight + 10)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 4
contentContainer.ScrollBarImageColor3 = CONFIG.Colors.Accent
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentContainer.Parent = mainContainer

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, CONFIG.Sizes.Spacing)
contentLayout.Parent = contentContainer

-- UI Builder Functions
local layoutOrder = 0
local function getNextOrder()
    layoutOrder = layoutOrder + 1
    return layoutOrder
end

local function createSection(title, showHeader)
    local section = Instance.new("Frame")
    section.Name = title
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.LayoutOrder = getNextOrder()
    section.Parent = contentContainer
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Padding = UDim.new(0, 6)
    sectionLayout.Parent = section
    
    -- Section Header (optional)
    if showHeader ~= false then
        local header = Instance.new("TextLabel")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundTransparency = 1
        header.Text = title
        header.TextColor3 = CONFIG.Colors.Text
        header.Font = Enum.Font.GothamBold
        header.TextSize = 14
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.LayoutOrder = 0
        header.Parent = section
    end
    
    return section
end

local function createButton(parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ButtonHeight)
    btn.BackgroundColor3 = color or CONFIG.Colors.Secondary
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = CONFIG.Colors.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.LayoutOrder = getNextOrder()
    btn.Parent = parent
    
    createCorner(6).Parent = btn
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(btn.BackgroundColor3.R * 255 + 20, 255) / 255,
                math.min(btn.BackgroundColor3.G * 255 + 20, 255) / 255,
                math.min(btn.BackgroundColor3.B * 255 + 20, 255) / 255
            )
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = color or CONFIG.Colors.Secondary
        }):Play()
    end)
    
    return btn
end

local function createToggle(parent, text, callback)
    local state = false
    local btn = createButton(parent, text .. " OFF", CONFIG.Colors.Secondary)
    
    local function updateState()
        state = not state
        btn.Text = text .. (state and " ON" or " OFF")
        btn.BackgroundColor3 = state and CONFIG.Colors.Success or CONFIG.Colors.Secondary
        if callback then callback(state) end
    end
    
    btn.MouseButton1Click:Connect(updateState)
    
    return btn, function() return state end, function(newState)
        if state ~= newState then updateState() end
    end
end

local function createTextBox(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ButtonHeight)
    box.BackgroundColor3 = CONFIG.Colors.Secondary
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = placeholder
    box.TextColor3 = CONFIG.Colors.Text
    box.PlaceholderColor3 = CONFIG.Colors.TextDim
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.LayoutOrder = getNextOrder()
    box.Parent = parent
    
    createCorner(6).Parent = box
    createPadding(8).Parent = box
    
    return box
end

local function loadExternalScript(url, section, scriptName)
    task.spawn(function()
        local success, err = pcall(function()
            local source = game:HttpGet(url)
            local compiled, compileErr = loadstring(source, "@" .. scriptName)
            
            if not compiled then
                error("Compile failed: " .. tostring(compileErr))
            end
            
            -- Create sandboxed environment
            local env = setmetatable({
                -- UI Builder Functions
                createButton = function(text, color) return createButton(section, text, color) end,
                createToggle = function(text, callback) return createToggle(section, text, callback) end,
                createTextBox = function(placeholder) return createTextBox(section, placeholder) end,
                
                -- Legacy support
                MakeButton = function(text) return createButton(section, text) end,
                MakeToggle = function(p, text, callback) return createToggle(p or section, text, callback) end,
                MakeLabel = function(text)
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 0, 24)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = text
                    lbl.TextColor3 = CONFIG.Colors.Text
                    lbl.Font = Enum.Font.GothamSemibold
                    lbl.TextSize = 13
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.LayoutOrder = getNextOrder()
                    lbl.Parent = section
                    return lbl
                end,
                MakeTextBox = function(text) return createTextBox(section, text) end,
                
                content = section,
                screenGui = screenGui,
                assignOrder = getNextOrder,
                safeParent = safeParent,
                
                -- Roblox globals
                game = game,
                workspace = workspace,
                LocalPlayer = LocalPlayer,
                Players = Players,
                UserInputService = UserInputService,
                RunService = RunService,
                TweenService = TweenService,
                
                -- Data types
                Instance = Instance,
                Vector3 = Vector3,
                Vector2 = Vector2,
                CFrame = CFrame,
                Color3 = Color3,
                UDim2 = UDim2,
                UDim = UDim,
                Enum = Enum,
                
                -- Standard library
                print = print,
                warn = warn,
                error = error,
                pcall = pcall,
                task = task,
                wait = task.wait,
                spawn = task.spawn,
                
                -- Utilities
                math = math,
                table = table,
                string = string,
                tostring = tostring,
                tonumber = tonumber,
                pairs = pairs,
                ipairs = ipairs,
                next = next,
                type = type,
                
                _G = _G
            }, { __index = getfenv() })
            
            setfenv(compiled, env)
            compiled()
        end)
        
        if not success then
            warn("[" .. scriptName .. "] Failed to load:", err)
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Size = UDim2.new(1, 0, 0, 24)
            errorLabel.BackgroundTransparency = 1
            errorLabel.Text = "⚠️ " .. scriptName .. " load failed"
            errorLabel.TextColor3 = CONFIG.Colors.Danger
            errorLabel.Font = Enum.Font.Gotham
            errorLabel.TextSize = 12
            errorLabel.TextXAlignment = Enum.TextXAlignment.Left
            errorLabel.LayoutOrder = getNextOrder()
            errorLabel.Parent = section
        end
    end)
end

-- Load External Tools
local movementSection = createSection("Movement Tools")
loadExternalScript(
    "https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/main/shirayukimikoto_movement_tools.lua",
    movementSection,
    "MovementTools"
)

-- Teleport Tools Section
local teleportSection = createSection("Teleport Tools")
local teleportToolsGui = nil
local teleportToolsLoaded = false

local teleportBtn = createButton(teleportSection, "Open Teleport Tools", CONFIG.Colors.Accent)
teleportBtn.MouseButton1Click:Connect(function()
    -- Load the script if not already loaded
    if not teleportToolsLoaded then
        task.spawn(function()
            local success, err = pcall(function()
                local url = "https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/main/shirayukimikoto_teleport_tools.lua"
                local source = game:HttpGet(url)
                local compiled, compileErr = loadstring(source, "@TeleportTools")
                
                if not compiled then
                    error("Compile failed: " .. tostring(compileErr))
                end
                
                -- Create a container frame for teleport tools
                local tpGui = Instance.new("ScreenGui")
                tpGui.Name = "ShirayukiTeleportTools"
                tpGui.ResetOnSpawn = false
                tpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                safeParent(tpGui)
                
                local tpFrame = Instance.new("Frame")
                tpFrame.Name = "TeleportFrame"
                tpFrame.Size = UDim2.new(0, 320, 0, 480)
                tpFrame.Position = UDim2.new(0.5, 200, 0.5, 0)
                tpFrame.AnchorPoint = Vector2.new(0, 0.5)
                tpFrame.BackgroundColor3 = CONFIG.Colors.Primary
                tpFrame.BorderSizePixel = 0
                tpFrame.Active = true
                tpFrame.Parent = tpGui
                
                createCorner(CONFIG.Sizes.CornerRadius).Parent = tpFrame
                
                -- Header for teleport tools
                local tpHeader = Instance.new("Frame")
                tpHeader.Name = "Header"
                tpHeader.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.HeaderHeight)
                tpHeader.BackgroundColor3 = CONFIG.Colors.Secondary
                tpHeader.BorderSizePixel = 0
                tpHeader.Parent = tpFrame
                
                createCorner(CONFIG.Sizes.CornerRadius).Parent = tpHeader
                
                local tpTitle = Instance.new("TextLabel")
                tpTitle.Size = UDim2.new(1, -50, 1, 0)
                tpTitle.Position = UDim2.new(0, 15, 0, 0)
                tpTitle.BackgroundTransparency = 1
                tpTitle.Text = "Teleport Tools"
                tpTitle.TextColor3 = CONFIG.Colors.Text
                tpTitle.Font = Enum.Font.GothamBold
                tpTitle.TextSize = 16
                tpTitle.TextXAlignment = Enum.TextXAlignment.Left
                tpTitle.Parent = tpHeader
                
                -- Close button for teleport tools
                local tpCloseBtn = Instance.new("TextButton")
                tpCloseBtn.Size = UDim2.new(0, 35, 0, 35)
                tpCloseBtn.Position = UDim2.new(1, -40, 0.5, 0)
                tpCloseBtn.AnchorPoint = Vector2.new(0, 0.5)
                tpCloseBtn.BackgroundColor3 = CONFIG.Colors.Danger
                tpCloseBtn.BorderSizePixel = 0
                tpCloseBtn.Text = "×"
                tpCloseBtn.TextColor3 = CONFIG.Colors.Text
                tpCloseBtn.Font = Enum.Font.GothamBold
                tpCloseBtn.TextSize = 20
                tpCloseBtn.Parent = tpHeader
                
                createCorner(6).Parent = tpCloseBtn
                
                tpCloseBtn.MouseButton1Click:Connect(function()
                    tpGui.Enabled = false
                end)
                
                -- Make header draggable
                local dragging = false
                local dragInput, dragStart, startPos
                
                tpHeader.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        dragStart = input.Position
                        startPos = tpFrame.Position
                        
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end)
                
                tpHeader.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        dragInput = input
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input == dragInput and dragging then
                        local delta = input.Position - dragStart
                        tpFrame.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end)
                
                -- Content container
                local tpContent = Instance.new("ScrollingFrame")
                tpContent.Name = "Content"
                tpContent.Size = UDim2.new(1, -20, 1, -CONFIG.Sizes.HeaderHeight - 20)
                tpContent.Position = UDim2.new(0, 10, 0, CONFIG.Sizes.HeaderHeight + 10)
                tpContent.BackgroundTransparency = 1
                tpContent.BorderSizePixel = 0
                tpContent.ScrollBarThickness = 4
                tpContent.ScrollBarImageColor3 = CONFIG.Colors.Accent
                tpContent.CanvasSize = UDim2.new(0, 0, 0, 0)
                tpContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
                tpContent.Parent = tpFrame
                
                local tpLayout = Instance.new("UIListLayout")
                tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
                tpLayout.Padding = UDim.new(0, 6)
                tpLayout.Parent = tpContent
                
                -- UI Helper functions for teleport script
                local function MakeLabel(text)
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 0, 24)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = text
                    lbl.TextColor3 = CONFIG.Colors.Text
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 13
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.LayoutOrder = getNextOrder()
                    return lbl
                end
                
                local function MakeButton(text)
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ButtonHeight)
                    btn.BackgroundColor3 = CONFIG.Colors.Secondary
                    btn.BorderSizePixel = 0
                    btn.Text = text
                    btn.TextColor3 = CONFIG.Colors.Text
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 13
                    btn.AutoButtonColor = false
                    btn.LayoutOrder = getNextOrder()
                    
                    createCorner(6).Parent = btn
                    
                    btn.MouseEnter:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.min(btn.BackgroundColor3.R * 255 + 20, 255) / 255,
                                math.min(btn.BackgroundColor3.G * 255 + 20, 255) / 255,
                                math.min(btn.BackgroundColor3.B * 255 + 20, 255) / 255
                            )
                        }):Play()
                    end)
                    
                    btn.MouseLeave:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.2), {
                            BackgroundColor3 = CONFIG.Colors.Secondary
                        }):Play()
                    end)
                    
                    return btn
                end
                
                local function MakeTextBox(placeholder)
                    local box = Instance.new("TextBox")
                    box.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ButtonHeight)
                    box.BackgroundColor3 = CONFIG.Colors.Secondary
                    box.BorderSizePixel = 0
                    box.Text = ""
                    box.PlaceholderText = placeholder
                    box.TextColor3 = CONFIG.Colors.Text
                    box.PlaceholderColor3 = CONFIG.Colors.TextDim
                    box.Font = Enum.Font.Gotham
                    box.TextSize = 13
                    box.ClearTextOnFocus = false
                    box.LayoutOrder = getNextOrder()
                    
                    createCorner(6).Parent = box
                    createPadding(8).Parent = box
                    
                    return box
                end
                
                local function MakeToggle(parent, text, callback)
                    local state = false
                    local btn = MakeButton(text .. " OFF")
                    btn.Parent = parent
                    
                    local function updateState()
                        state = not state
                        btn.Text = text .. (state and " ON" or " OFF")
                        btn.BackgroundColor3 = state and CONFIG.Colors.Success or CONFIG.Colors.Secondary
                        if callback then callback(state) end
                    end
                    
                    btn.MouseButton1Click:Connect(updateState)
                    
                    return btn
                end
                
                -- Create comprehensive sandboxed environment
                local env = setmetatable({
                    -- UI Functions
                    MakeLabel = MakeLabel,
                    MakeButton = MakeButton,
                    MakeTextBox = MakeTextBox,
                    MakeToggle = MakeToggle,
                    tpSection = tpContent,
                    
                    -- Roblox services
                    game = game,
                    workspace = workspace,
                    LocalPlayer = LocalPlayer,
                    Players = Players,
                    UserInputService = UserInputService,
                    RunService = RunService,
                    TweenService = TweenService,
                    
                    -- Data types
                    Instance = Instance,
                    Vector3 = Vector3,
                    Vector2 = Vector2,
                    CFrame = CFrame,
                    Color3 = Color3,
                    UDim2 = UDim2,
                    UDim = UDim,
                    Enum = Enum,
                    
                    -- Standard library
                    print = print,
                    warn = warn,
                    error = error,
                    assert = assert,
                    pcall = pcall,
                    task = task,
                    wait = task.wait,
                    spawn = task.spawn,
                    
                    -- Utilities
                    math = math,
                    table = table,
                    string = string,
                    tostring = tostring,
                    tonumber = tonumber,
                    pairs = pairs,
                    ipairs = ipairs,
                    next = next,
                    type = type,
                    
                    -- Global storage
                    _G = _G
                }, { 
                    __index = function(t, k)
                        return getfenv(0)[k]
                    end
                })
                
                setfenv(compiled, env)
                compiled()
                
                teleportToolsGui = tpGui
                teleportToolsLoaded = true
                
                teleportBtn.Text = "Toggle Teleport Tools"
                teleportBtn.BackgroundColor3 = CONFIG.Colors.Success
            end)
            
            if not success then
                warn("[Teleport Tools] Load failed:", err)
                teleportBtn.Text = "❌ Load Failed"
                teleportBtn.BackgroundColor3 = CONFIG.Colors.Danger
                task.wait(2)
                teleportBtn.Text = "Open Teleport Tools"
                teleportBtn.BackgroundColor3 = CONFIG.Colors.Accent
                teleportToolsLoaded = false
            end
        end)
    else
        -- Toggle visibility if already loaded
        if teleportToolsGui then
            teleportToolsGui.Enabled = not teleportToolsGui.Enabled
        end
    end
end)

local btoolsSection = createSection("BTools")
local btoolsBtn = createButton(btoolsSection, "Open BTools GUI", CONFIG.Colors.Accent)
btoolsBtn.MouseButton1Click:Connect(function()
    loadExternalScript(
        "https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/main/shirayukimikoto_btools_gui.lua",
        btoolsSection,
        "BTools"
    )
end)

local tracerSection = createSection("Player Tracer")
local tracerState = {
    players = {},
    connections = {}
}

local function setupPlayerTracer(enabled)
    if enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                task.spawn(function()
                    local char = plr.Character or plr.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart", 5)
                    if not hrp then return end
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "TracerGui"
                    billboard.Adornee = hrp
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = hrp
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 0.3
                    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = billboard
                    
                    createCorner(6).Parent = label
                    
                    tracerState.players[plr] = billboard
                    
                    local conn = RunService.Heartbeat:Connect(function()
                        if not plr.Parent or not LocalPlayer.Character then return end
                        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp and hrp.Parent then
                            local dist = (hrp.Position - myHrp.Position).Magnitude
                            label.Text = string.format("%s\n%d studs", plr.Name, math.floor(dist))
                        end
                    end)
                    
                    table.insert(tracerState.connections, conn)
                end)
            end
        end
    else
        for _, billboard in pairs(tracerState.players) do
            billboard:Destroy()
        end
        for _, conn in ipairs(tracerState.connections) do
            conn:Disconnect()
        end
        tracerState.players = {}
        tracerState.connections = {}
    end
end

createToggle(tracerSection, "Player Tracer", setupPlayerTracer)

local emoteSection = createSection("Emote System")
local emoteBtn = createButton(emoteSection, "Open Emote GUI", CONFIG.Colors.Accent)
emoteBtn.MouseButton1Click:Connect(function()
    loadExternalScript(
        "https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/refs/heads/main/emote_plus_gui.lua",
        emoteSection,
        "EmoteGUI"
    )
end)

local dodgeSection = createSection("Side Dodge (Q/E)")
loadExternalScript(
    "https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/main/shirayukimikoto_side_dodge.lua",
    dodgeSection,
    "SideDodge"
)

local loggerSection = createSection("Client Logger")
local loggerBtn = createButton(loggerSection, "Load Client Logger", CONFIG.Colors.Secondary)
loggerBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local success = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/main/fujiwarasayo_client_logger.lua"))()
        end)
        
        if success then
            loggerBtn.Text = "✅ Logger Loaded"
            loggerBtn.BackgroundColor3 = CONFIG.Colors.Success
        else
            loggerBtn.Text = "❌ Load Failed"
            loggerBtn.BackgroundColor3 = CONFIG.Colors.Danger
        end
        
        task.wait(2)
        loggerBtn.Text = "Load Client Logger"
        loggerBtn.BackgroundColor3 = CONFIG.Colors.Secondary
    end)
end)

local dexSection = createSection("Dex Explorer")
local dexBtn = createButton(dexSection, "Open Dex Explorer", CONFIG.Colors.Accent)
dexBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
end)

local topkSection = createSection("Topk3k Client")
local topkBtn = createButton(topkSection, "Open Topk3k", CONFIG.Colors.Accent)
topkBtn.MouseButton1Click:Connect(function()
    loadExternalScript(
        "https://raw.githubusercontent.com/scr1ptyureishirayukimikotofujiwarasayo/our-roblox-scripts/main/fujiwarasayo_topk3k.lua",
        topkSection,
        "Topk3k"
    )
end)

print("✅ shirayukimikoto's mod menu loaded successfully!")
