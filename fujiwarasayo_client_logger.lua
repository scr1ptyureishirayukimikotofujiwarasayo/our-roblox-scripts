--[[
    SHIRAYUKIMIKOTO CLIENT LOGGER (REBUILT + FIXED)
    Fully compatible with new menu system
    Popup size: 460 × 300
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

--========================================================--
--  CONFIG
--========================================================--

local CONFIG = {
    Colors = {
        Primary = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 40),
        Header = Color3.fromRGB(25, 25, 40),
        Accent = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Danger = Color3.fromRGB(237, 66, 69),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 190),
    },
    Sizes = {
        Width = 500,
        Height = 350,
        HeaderHeight = 45,
        ButtonHeight = 32,
        Corner = 8
    }
}

--========================================================--
--  UTILITIES
--========================================================--

local function safeParent(gui)
    local ok = pcall(function()
        gui.Parent = CoreGui
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function createCorner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or CONFIG.Sizes.Corner)
    return c
end

local function createPadding(all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all)
    padding.PaddingBottom = UDim.new(0, all)
    padding.PaddingLeft = UDim.new(0, all)
    padding.PaddingRight = UDim.new(0, all)
    return padding
end

--========================================================--
--  LOGGER STATE
--========================================================--

local loggerState = {
    enabled = false,
    gui = nil,
    scroll = nil,
    hooks = {},
    oldFunctions = {},
    filterButtons = {},
}

local filters = {
    print = true,
    remote = true,
    func = true,
    physics = true,
    ui = true,
    script = true,
    errors = true
}

local logBuffer = {}
local maxLogLines = 500

--========================================================--
--  LOG UTILITIES
--========================================================--

local function addLog(msg, logType)
    if not loggerState.enabled then return end

    logType = logType or "LOG"

    table.insert(logBuffer, {
        message = msg,
        type = logType,
        timestamp = os.time()
    })

    if #logBuffer > maxLogLines then
        table.remove(logBuffer, 1)
    end

    if loggerState.scroll then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = CONFIG.Colors.Text
        lbl.Font = Enum.Font.Roboto
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true

        -- Color code by type
        local typeColors = {
            PRINT = CONFIG.Colors.Text,
            WARN = Color3.fromRGB(255, 200, 0),
            ERROR = CONFIG.Colors.Danger,
            REMOTE = CONFIG.Colors.Accent,
            FUNCTION = Color3.fromRGB(100, 200, 255),
            SCRIPT = Color3.fromRGB(150, 255, 150),
        }

        lbl.TextColor3 = typeColors[logType] or CONFIG.Colors.Text
        lbl.Text = "[" .. logType .. "] " .. msg
        lbl.Parent = loggerState.scroll
    end
end

--========================================================--
--  CREATE LOGGER GUI
--========================================================--

local function createLoggerGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ShirayukiClientLogger"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    safeParent(gui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, CONFIG.Sizes.Width, 0, CONFIG.Sizes.Height)
    frame.Position = UDim2.new(0.5, -CONFIG.Sizes.Width / 2, 0.5, 50)
    frame.BackgroundColor3 = CONFIG.Colors.Primary
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    createCorner(CONFIG.Sizes.Corner).Parent = frame

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.HeaderHeight)
    header.BackgroundColor3 = CONFIG.Colors.Secondary
    header.BorderSizePixel = 0
    header.Parent = frame
    createCorner(CONFIG.Sizes.Corner).Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Client Logger"
    title.TextColor3 = CONFIG.Colors.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Close button
    local closeBtn = Instance.new("TextButton")
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
        gui.Enabled = false
    end)

    -- Dragging
    local dragging = false
    local dragStart, startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Filter Panel
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, -20, 0, 45)
    filterFrame.Position = UDim2.new(0, 10, 0, CONFIG.Sizes.HeaderHeight + 8)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = frame

    local filterLayout = Instance.new("UIGridLayout")
    filterLayout.CellSize = UDim2.new(0, 75, 0, 32)
    filterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    filterLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    filterLayout.FillDirection = Enum.FillDirection.Horizontal
    filterLayout.Padding = UDim.new(0, 6)
    filterLayout.Parent = filterFrame

    local function createFilterButton(name, filterKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 75, 0, 32)
        btn.BackgroundColor3 = CONFIG.Colors.Accent
        btn.BorderSizePixel = 0
        btn.TextColor3 = CONFIG.Colors.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Text = name
        btn.AutoButtonColor = false
        btn.Parent = filterFrame
        createCorner(6).Parent = btn

        loggerState.filterButtons[filterKey] = btn

        btn.MouseButton1Click:Connect(function()
            filters[filterKey] = not filters[filterKey]
            btn.BackgroundColor3 = filters[filterKey] and CONFIG.Colors.Success or CONFIG.Colors.Accent
        end)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(
                math.min(btn.BackgroundColor3.R * 255 + 20, 255) / 255,
                math.min(btn.BackgroundColor3.G * 255 + 20, 255) / 255,
                math.min(btn.BackgroundColor3.B * 255 + 20, 255) / 255
            )
        end)

        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = filters[filterKey] and CONFIG.Colors.Success or CONFIG.Colors.Accent
        end)

        return btn
    end

    createFilterButton("Print", "print")
    createFilterButton("Remote", "remote")
    createFilterButton("Func", "func")
    createFilterButton("Script", "script")
    createFilterButton("Error", "errors")

    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 80, 0, 32)
    clearBtn.BackgroundColor3 = CONFIG.Colors.Danger
    clearBtn.BorderSizePixel = 0
    clearBtn.TextColor3 = CONFIG.Colors.Text
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.TextSize = 11
    clearBtn.Text = "CLEAR"
    clearBtn.AutoButtonColor = false
    clearBtn.Parent = filterFrame
    createCorner(6).Parent = clearBtn

    clearBtn.MouseButton1Click:Connect(function()
        logBuffer = {}
        for _, child in ipairs(loggerState.scroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end)

    -- Log Scroll Area
    local logScroll = Instance.new("ScrollingFrame")
    logScroll.Size = UDim2.new(1, -20, 1, -CONFIG.Sizes.HeaderHeight - 60)
    logScroll.Position = UDim2.new(0, 10, 0, CONFIG.Sizes.HeaderHeight + 60)
    logScroll.BackgroundTransparency = 1
    logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logScroll.ScrollBarThickness = 5
    logScroll.ScrollBarImageColor3 = CONFIG.Colors.Accent
    logScroll.Parent = frame

    local logLayout = Instance.new("UIListLayout")
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Padding = UDim.new(0, 2)
    logLayout.Parent = logScroll

    loggerState.gui = gui
    loggerState.scroll = logScroll

    return gui
end

createLoggerGui()

--========================================================--
--  HOOKING FUNCTIONS
--========================================================--

local function hookPrints()
    if loggerState.oldFunctions.print then return end

    loggerState.oldFunctions.print = print
    loggerState.oldFunctions.warn = warn

    getgenv().print = function(...)
        loggerState.oldFunctions.print(...)
        if filters.print and loggerState.enabled then
            addLog(table.concat({...}, " "), "PRINT")
        end
    end

    getgenv().warn = function(...)
        loggerState.oldFunctions.warn(...)
        if filters.print and loggerState.enabled then
            addLog(table.concat({...}, " "), "WARN")
        end
    end
end

local function hookRemotes()
    local hooked = {}

    local function hookObject(obj)
        if hooked[obj] then return end

        if obj:IsA("RemoteEvent") then
            hooked[obj] = true
            local oldOnClientEvent = obj.OnClientEvent
            
            local conn = obj.OnClientEvent:Connect(function(...)
                if filters.remote and loggerState.enabled then
                    addLog("RemoteEvent: " .. obj.Name, "REMOTE")
                end
            end)
            table.insert(loggerState.hooks, function() conn:Disconnect() end)

        elseif obj:IsA("RemoteFunction") then
            hooked[obj] = true
            if not loggerState.oldFunctions["RemoteFunc_" .. obj] then
                loggerState.oldFunctions["RemoteFunc_" .. obj] = obj.OnClientInvoke

                local oldFunc = obj.OnClientInvoke
                obj.OnClientInvoke = function(...)
                    if filters.func and loggerState.enabled then
                        addLog("RemoteFunction: " .. obj.Name, "FUNCTION")
                    end
                    if oldFunc then
                        return oldFunc(...)
                    end
                end
            end
        end
    end

    -- Hook existing objects
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function() hookObject(obj) end)
    end

    -- Hook new objects
    local descendantAdded = game.DescendantAdded:Connect(function(obj)
        pcall(function() hookObject(obj) end)
    end)

    table.insert(loggerState.hooks, function() descendantAdded:Disconnect() end)
end

local function hookScripts()
    local hooked = {}

    local function hookObject(obj)
        if hooked[obj] then return end

        if obj:IsA("LocalScript") then
            hooked[obj] = true
            if filters.script and loggerState.enabled then
                addLog(obj:GetFullName(), "SCRIPT")
            end
        end
    end

    -- Hook existing objects
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function() hookObject(obj) end)
    end

    -- Hook new objects
    local descendantAdded = game.DescendantAdded:Connect(function(obj)
        pcall(function() hookObject(obj) end)
    end)

    table.insert(loggerState.hooks, function() descendantAdded:Disconnect() end)
end

--========================================================--
--  ENABLE / DISABLE
--========================================================--

local function Enable()
    if loggerState.enabled then return end
    loggerState.enabled = true
    loggerState.gui.Enabled = true

    logBuffer = {}

    hookPrints()
    hookRemotes()
    hookScripts()

    addLog("Logger enabled", "LOG")
end

local function Disable()
    if not loggerState.enabled then return end
    loggerState.enabled = false
    loggerState.gui.Enabled = false

    -- Disconnect all hooks
    for _, fn in ipairs(loggerState.hooks) do
        pcall(fn)
    end
    loggerState.hooks = {}

    -- Restore old functions
    if loggerState.oldFunctions.print then
        getgenv().print = loggerState.oldFunctions.print
        getgenv().warn = loggerState.oldFunctions.warn
        loggerState.oldFunctions.print = nil
        loggerState.oldFunctions.warn = nil
    end

    addLog("Logger disabled", "LOG")
end

local function Toggle()
    if loggerState.enabled then
        Disable()
    else
        Enable()
    end
end

--========================================================--
--  MENU INTEGRATION
--========================================================--

-- This allows the menu to call these functions
_G.ShirayukiClientLogger = {
    Enable = Enable,
    Disable = Disable,
    Toggle = Toggle,
    IsEnabled = function() return loggerState.enabled end,
    GetGui = function() return loggerState.gui end
}

-- If called from menu system
if MakeButton then
    MakeButton("Start Logger").MouseButton1Click:Connect(Enable)
end

if MakeToggle then
    MakeToggle("Client Logger", function(state)
        if state then Enable() else Disable() end
    end)
end

return {
    Enable = Enable,
    Disable = Disable,
    Toggle = Toggle,
    IsEnabled = function() return loggerState.enabled end
}
