--========================================================--
--  SHIRAYUKIMIKOTO CLIENT LOGGER (REBUILT + FIXED)
--  Fully compatible with new menu system
--  Popup size: 460 × 300
--========================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

--========================================================--
--  CONFIG (Matches your new UI theme)
--========================================================--

local CONFIG = {
    Colors = {
        Primary = Color3.fromRGB(30, 30, 60),
        Header = Color3.fromRGB(0, 85, 170),
        Button = Color3.fromRGB(0, 120, 215),
        Danger = Color3.fromRGB(180, 60, 60),
        Text = Color3.new(1, 1, 1),
    },
    Sizes = {
        Width = 460,
        Height = 300,
        HeaderHeight = 28,
        ButtonHeight = 24,
        Corner = 6
    }
}

--========================================================--
--  SAFE PARENT
--========================================================--

local function safeParent(gui)
    local ok = pcall(function()
        gui.Parent = CoreGui
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

--========================================================--
--  LOGGER STATE
--========================================================--

local loggerGui
local loggerScroll
local loggerEnabled = false

local hooks = {}
local oldPrint, oldWarn
local oldInvoke = {}

local filters = {
    print = true,
    remote = true,
    func = true,
    physics = true,
    ui = true,
    script = true
}

--========================================================--
--  UI HELPERS
--========================================================--

local function corner(parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, CONFIG.Sizes.Corner)
    c.Parent = parent
end

local function makeButton(parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, CONFIG.Sizes.ButtonHeight)
    btn.BackgroundColor3 = color or CONFIG.Colors.Button
    btn.TextColor3 = CONFIG.Colors.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Parent = parent
    corner(btn)
    return btn
end

local function logLine(msg)
    if not loggerEnabled then return end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = CONFIG.Colors.Text
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = msg
    lbl.Parent = loggerScroll
end

--========================================================--
--  CREATE LOGGER GUI
--========================================================--

local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ShirayukiClientLogger"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    safeParent(gui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, CONFIG.Sizes.Width, 0, CONFIG.Sizes.Height)
    frame.Position = UDim2.new(0, 380, 0, 100)
    frame.BackgroundColor3 = CONFIG.Colors.Primary
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    corner(frame)

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.HeaderHeight)
    header.BackgroundColor3 = CONFIG.Colors.Header
    header.BorderSizePixel = 0
    header.Parent = frame
    corner(header)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Client Logger"
    title.TextColor3 = CONFIG.Colors.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Close button
    local closeBtn = makeButton(header, "×", CONFIG.Colors.Danger)
    closeBtn.Size = UDim2.new(0, 28, 0, 22)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -11)
    closeBtn.TextSize = 16

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
        end
    end)

    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Filters
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, -10, 0, 26)
    filterFrame.Position = UDim2.new(0, 5, 0, CONFIG.Sizes.HeaderHeight + 2)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.Parent = filterFrame

    local function toggleFilter(name)
        filters[name] = not filters[name]
    end

    makeButton(filterFrame, "Print", CONFIG.Colors.Button).MouseButton1Click:Connect(function() toggleFilter("print") end)
    makeButton(filterFrame, "Remote", CONFIG.Colors.Button).MouseButton1Click:Connect(function() toggleFilter("remote") end)
    makeButton(filterFrame, "Func", CONFIG.Colors.Button).MouseButton1Click:Connect(function() toggleFilter("func") end)
    makeButton(filterFrame, "Phys", CONFIG.Colors.Button).MouseButton1Click:Connect(function() toggleFilter("physics") end)
    makeButton(filterFrame, "UI", CONFIG.Colors.Button).MouseButton1Click:Connect(function() toggleFilter("ui") end)
    makeButton(filterFrame, "Script", CONFIG.Colors.Button).MouseButton1Click:Connect(function() toggleFilter("script") end)

    -- Clear button
    local clearBtn = makeButton(filterFrame, "CLEAR", CONFIG.Colors.Danger)
    clearBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(loggerScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end)

    -- Log area
    loggerScroll = Instance.new("ScrollingFrame")
    loggerScroll.Size = UDim2.new(1, -10, 1, -60)
    loggerScroll.Position = UDim2.new(0, 5, 0, 60)
    loggerScroll.BackgroundTransparency = 1
    loggerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    loggerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    loggerScroll.ScrollBarThickness = 6
    loggerScroll.Parent = frame

    local logLayout = Instance.new("UIListLayout")
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Padding = UDim.new(0, 2)
    logLayout.Parent = loggerScroll

    loggerGui = gui
end

createGui()

--========================================================--
--  HOOKING
--========================================================--

local function hookPrints()
    if oldPrint then return end

    oldPrint = print
    oldWarn = warn

    getgenv().print = function(...)
        oldPrint(...)
        if filters.print then
            logLine("[PRINT] " .. table.concat({...}, " "))
        end
    end

    getgenv().warn = function(...)
        oldWarn(...)
        if filters.print then
            logLine("[WARN] " .. table.concat({...}, " "))
        end
    end
end

local function hookRemotes()
    local function hook(obj)
        if obj:IsA("RemoteEvent") then
            local c = obj.OnClientEvent:Connect(function(...)
                if filters.remote then
                    logLine("[RemoteEvent] " .. obj.Name)
                end
            end)
            table.insert(hooks, function() c:Disconnect() end)

        elseif obj:IsA("RemoteFunction") then
            if not oldInvoke[obj] then
                oldInvoke[obj] = obj.OnClientInvoke
                obj.OnClientInvoke = function(...)
                    if filters.func then
                        logLine("[RemoteFunction] " .. obj.Name)
                    end
                    if oldInvoke[obj] then
                        return oldInvoke[obj](...)
                    end
                end
            end
        end
    end

    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function() hook(obj) end)
    end

    local added = game.DescendantAdded:Connect(function(obj)
        pcall(function() hook(obj) end)
    end)

    table.insert(hooks, function() added:Disconnect() end)
end

local function hookLocalScripts()
    local function hook(obj)
        if obj:IsA("LocalScript") then
            if filters.script then
                logLine("[LocalScript] " .. obj:GetFullName())
            end
        end
    end

    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function() hook(obj) end)
    end

    local added = game.DescendantAdded:Connect(function(obj)
        pcall(function() hook(obj) end)
    end)

    table.insert(hooks, function() added:Disconnect() end)
end

--========================================================--
--  ENABLE / DISABLE
--========================================================--

local function Enable()
    if loggerEnabled then return end
    loggerEnabled = true
    loggerGui.Enabled = true

    hookPrints()
    hookRemotes()
    hookLocalScripts()

    logLine("Logger enabled")
end

local function Disable()
    if not loggerEnabled then return end
    loggerEnabled = false
    loggerGui.Enabled = false

    for _, fn in ipairs(hooks) do
        pcall(fn)
    end
    hooks = {}

    for obj, old in pairs(oldInvoke) do
        pcall(function() obj.OnClientInvoke = old end)
    end
    oldInvoke = {}

    if oldPrint then
        getgenv().print = oldPrint
        getgenv().warn = oldWarn
        oldPrint, oldWarn = nil, nil
    end
end

local function Toggle()
    if loggerEnabled then Disable() else Enable() end
end

--========================================================--
--  RETURN API
--========================================================--

return {
    Enable = Enable,
    Disable = Disable,
    Toggle = Toggle,
    IsEnabled = function() return loggerEnabled end
}
