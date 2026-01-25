-- Client Logger Script
-- Logs client-side events, remotes, prints, and LocalScript activity

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local COLOR_PRIMARY = Color3.fromRGB(0, 85, 170)
local COLOR_BUTTON = Color3.fromRGB(0, 120, 215)
local COLOR_BG_DARK = Color3.fromRGB(30, 30, 60)
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
screenGui.Name = "ClientLoggerGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
safeParent(screenGui)

-- Logger State
local loggerGui
local loggerScroll
local loggerDragging = false
local loggerDragStart
local loggerStartPos
local loggerHooks = {}
local loggerRemoteOldInvoke = {}
local loggerOldPrint, loggerOldWarn, loggerOldError
local loggerEnabled = false
local filter_prints = true
local filter_remotes = true
local filter_functions = true
local filter_physics = true
local filter_ui = true
local filter_localscripts = true

local function CreateLoggerGui()
    loggerGui = Instance.new("Frame")
    loggerGui.Name = "ClientLoggerWindow"
    loggerGui.Size = UDim2.new(0, 460, 0, 300)
    loggerGui.Position = UDim2.new(0, 380, 0, 100)
    loggerGui.BackgroundColor3 = COLOR_BG_DARK
    loggerGui.BorderSizePixel = 0
    loggerGui.Active = true
    loggerGui.Visible = false
    loggerGui.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundColor3 = COLOR_PRIMARY
    title.BorderSizePixel = 0
    title.Text = "Client-side Event/Script Logger"
    title.TextColor3 = COLOR_TEXT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = loggerGui
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 6)
    pad.Parent = title
    
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, -10, 0, 30)
    filterFrame.Position = UDim2.new(0, 5, 0, 26)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = loggerGui
    
    local filterLayout = Instance.new("UIListLayout")
    filterLayout.FillDirection = Enum.FillDirection.Horizontal
    filterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    filterLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    filterLayout.Padding = UDim.new(0, 6)
    filterLayout.Parent = filterFrame
    
    local function MakeFilterToggle(text, default, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 65, 0, 24)
        btn.BackgroundColor3 = COLOR_BUTTON
        btn.TextColor3 = COLOR_TEXT
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        local state = default
        local function update()
            btn.Text = text .. (state and " ON" or " OFF")
        end
        update()
        btn.MouseButton1Click:Connect(function()
            state = not state
            update()
            callback(state)
        end)
        btn.Parent = filterFrame
        return btn
    end
    
    MakeFilterToggle("Print", true, function(v) filter_prints = v end)
    MakeFilterToggle("Remote", true, function(v) filter_remotes = v end)
    MakeFilterToggle("Func", true, function(v) filter_functions = v end)
    MakeFilterToggle("Phys", true, function(v) filter_physics = v end)
    MakeFilterToggle("UI", true, function(v) filter_ui = v end)
    MakeFilterToggle("Script", true, function(v) filter_localscripts = v end)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 50, 0, 24)
    clearBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    clearBtn.TextColor3 = COLOR_TEXT
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 12
    clearBtn.Text = "CLEAR"
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = filterFrame
    
    clearBtn.MouseButton1Click:Connect(function()
        if loggerScroll then
            for _, child in ipairs(loggerScroll:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
        end
    end)
    
    loggerScroll = Instance.new("ScrollingFrame")
    loggerScroll.Size = UDim2.new(1, -10, 1, -66)
    loggerScroll.Position = UDim2.new(0, 5, 0, 60)
    loggerScroll.BackgroundTransparency = 1
    loggerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    loggerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    loggerScroll.ScrollBarThickness = 6
    loggerScroll.Parent = loggerGui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = loggerScroll
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            loggerDragging = true
            loggerDragStart = input.Position
            loggerStartPos = loggerGui.Position
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            loggerDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if loggerDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - loggerDragStart
            loggerGui.Position = UDim2.new(
                loggerStartPos.X.Scale,
                loggerStartPos.X.Offset + delta.X,
                loggerStartPos.Y.Scale,
                loggerStartPos.Y.Offset + delta.Y
            )
        end
    end)
end

CreateLoggerGui()

local function Log(msg, category)
    if not loggerEnabled or not loggerScroll then return end
    
    if category == "print" and not filter_prints then return end
    if category == "remote" and not filter_remotes then return end
    if category == "function" and not filter_functions then return end
    if category == "physics" and not filter_physics then return end
    if category == "ui" and not filter_ui then return end
    if category == "localscript" and not filter_localscripts then return end
    
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, -4, 0, 18)
    line.BackgroundTransparency = 1
    line.TextColor3 = COLOR_TEXT
    line.Font = Enum.Font.Code
    line.TextSize = 13
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.Text = msg
    line.TextWrapped = false
    line.TextTruncate = Enum.TextTruncate.AtEnd
    line.Parent = loggerScroll
end

local function HookPrints()
    if loggerOldPrint then return end
    
    loggerOldPrint = print
    loggerOldWarn = warn
    
    getgenv().print = function(...)
        loggerOldPrint(...)
        local args = {...}
        local msg = ""
        for i, v in ipairs(args) do
            msg = msg .. tostring(v) .. (i < #args and " " or "")
        end
        Log("[PRINT] " .. msg, "print")
    end
    
    getgenv().warn = function(...)
        loggerOldWarn(...)
        local args = {...}
        local msg = ""
        for i, v in ipairs(args) do
            msg = msg .. tostring(v) .. (i < #args and " " or "")
        end
        Log("[WARN] " .. msg, "print")
    end
end

local function HookRemotes()
    local function hookRemote(obj)
        if obj:IsA("RemoteEvent") then
            local c = obj.OnClientEvent:Connect(function(...)
                local args = {...}
                local argStr = ""
                for i, v in ipairs(args) do
                    argStr = argStr .. tostring(v) .. (i < #args and ", " or "")
                end
                Log("[RemoteEvent] " .. obj:GetFullName() .. " (" .. argStr .. ")", "remote")
            end)
            table.insert(loggerHooks, function()
                c:Disconnect()
            end)
        elseif obj:IsA("RemoteFunction") then
            if not loggerRemoteOldInvoke[obj] then
                loggerRemoteOldInvoke[obj] = obj.OnClientInvoke
                obj.OnClientInvoke = function(...)
                    Log("[RemoteFunction] " .. obj:GetFullName(), "function")
                    if loggerRemoteOldInvoke[obj] then
                        return loggerRemoteOldInvoke[obj](...)
                    end
                end
                table.insert(loggerHooks, function()
                    if loggerRemoteOldInvoke[obj] then
                        obj.OnClientInvoke = loggerRemoteOldInvoke[obj]
                    end
                end)
            end
        end
    end
    
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            hookRemote(obj)
        end)
    end
    
    local c = game.DescendantAdded:Connect(function(obj)
        pcall(function()
            hookRemote(obj)
        end)
    end)
    table.insert(loggerHooks, function()
        c:Disconnect()
    end)
end

local function HookLocalScripts()
    local function hookScript(obj)
        if obj:IsA("LocalScript") then
            Log("[LocalScript Added] " .. obj:GetFullName(), "localscript")
            
            local propConn = obj:GetPropertyChangedSignal("Enabled"):Connect(function()
                Log("[LocalScript Toggled] " .. obj:GetFullName() .. " Enabled=" .. tostring(obj.Enabled), "localscript")
            end)
            table.insert(loggerHooks, function()
                propConn:Disconnect()
            end)
        end
    end
    
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            hookScript(obj)
        end)
    end
    
    local addedConn = game.DescendantAdded:Connect(function(obj)
        pcall(function()
            hookScript(obj)
        end)
    end)
    
    local removedConn = game.DescendantRemoving:Connect(function(obj)
        if obj:IsA("LocalScript") then
            Log("[LocalScript Removed] " .. obj:GetFullName(), "localscript")
        end
    end)
    
    table.insert(loggerHooks, function()
        addedConn:Disconnect()
        removedConn:Disconnect()
    end)
end

local function EnableLogger()
    if loggerEnabled then return end
    loggerEnabled = true
    loggerGui.Visible = true
    
    for _, fn in ipairs(loggerHooks) do
        pcall(fn)
    end
    loggerHooks = {}
    
    Log("Logger enabled", "print")
    HookPrints()
    HookRemotes()
    HookLocalScripts()
end

local function DisableLogger()
    if not loggerEnabled then return end
    loggerEnabled = false
    loggerGui.Visible = false
    
    for _, fn in ipairs(loggerHooks) do
        pcall(fn)
    end
    loggerHooks = {}
    
    for obj, old in pairs(loggerRemoteOldInvoke) do
        pcall(function()
            obj.OnClientInvoke = old
        end)
    end
    loggerRemoteOldInvoke = {}
    
    if loggerOldPrint then
        getgenv().print = loggerOldPrint
        getgenv().warn = loggerOldWarn
        loggerOldPrint, loggerOldWarn, loggerOldError = nil, nil, nil
    end
end

-- Public API
return {
    Enable = EnableLogger,
    Disable = DisableLogger,
    Toggle = function()
        if loggerEnabled then
            DisableLogger()
        else
            EnableLogger()
        end
    end,
    IsEnabled = function()
        return loggerEnabled
    end
}
