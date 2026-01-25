-- shirayukimikoto_teleport_tools.lua
-- Uses: MakeLabel, MakeButton, MakeTextBox, MakeToggle, tpSection or content
-- Standalone teleport tools: Anti-TP, TP to player, position saver (multi-save)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local container = tpSection or content

local function addLabel(text)
    local lbl = MakeLabel(text)
    lbl.Parent = container
    return lbl
end

local function addButton(text)
    local btn = MakeButton(text)
    btn.Parent = container
    return btn
end

local function addTextBox(placeholder)
    local tb = MakeTextBox(placeholder)
    tb.Parent = container
    return tb
end

local function addToggle(text, callback)
    local btn = MakeToggle(container, text, callback)
    return btn
end

-- 1. Anti-Teleport
addLabel("🛡️ Anti-Teleport")

local antiTpConn
local lastPos

addToggle("AntiTeleport", function(on)
    if antiTpConn then
        antiTpConn:Disconnect()
        antiTpConn = nil
    end

    if on then
        lastPos = nil
        antiTpConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if lastPos then
                local delta = hrp.Position - lastPos
                if delta.Magnitude > 50 then
                    hrp.CFrame = CFrame.new(lastPos)
                end
            end

            lastPos = hrp.Position
        end)
    end
end)

-- 2. Teleport to Player
addLabel("👤 Teleport to Player")

local tpInput = addTextBox("Type username")

local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 32)
row.BackgroundTransparency = 1
row.Parent = container

local tpBtn = MakeButton("Teleport")
tpBtn.Size = UDim2.new(0.48, -4, 1, 0)
tpBtn.Parent = row

local tpClosestBtn = MakeButton("TP Closest")
tpClosestBtn.Size = UDim2.new(0.48, -4, 1, 0)
tpClosestBtn.Position = UDim2.new(0.52, 0, 0, 0)
tpClosestBtn.Parent = row

local function findPlayers(partial)
    partial = partial:lower()
    local matches = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local uname = plr.Name:lower()
            local dname = (plr.DisplayName or ""):lower()
            if uname:find(partial, 1, true) or dname:find(partial, 1, true) then
                table.insert(matches, plr)
            end
        end
    end
    return matches
end

local function teleportTo(plr)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local tChar = plr.Character
    if not tChar then return end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end

    hrp.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
end

tpBtn.MouseButton1Click:Connect(function()
    local text = tpInput.Text:match("%S+")
    if not text then return end
    local matches = findPlayers(text)
    if matches[1] then
        teleportTo(matches[1])
    end
end)

tpClosestBtn.MouseButton1Click:Connect(function()
    local text = tpInput.Text:match("%S+")
    if not text then return end

    local matches = findPlayers(text)
    if #matches == 0 then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        teleportTo(matches[1])
        return
    end

    local closest, dist = nil, math.huge
    for _, plr in ipairs(matches) do
        local tChar = plr.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if tRoot then
            local d = (tRoot.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                closest = plr
            end
        end
    end

    if closest then
        teleportTo(closest)
    end
end)

-- 3. Position Saver
addLabel("📍 Position Saver")

local saveNameBox = addTextBox("Position name")
local saveBtn = addButton("Save Current Position")

local savedPositions = _G.shirayukimikoto_savedPositions or {}
_G.shirayukimikoto_savedPositions = savedPositions

local posListFrame = Instance.new("ScrollingFrame")
posListFrame.Size = UDim2.new(1, 0, 0, 140)
posListFrame.BackgroundTransparency = 1
posListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
posListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
posListFrame.ScrollBarThickness = 4
posListFrame.Parent = container

local posLayout = Instance.new("UIListLayout")
posLayout.FillDirection = Enum.FillDirection.Vertical
posLayout.SortOrder = Enum.SortOrder.LayoutOrder
posLayout.Padding = UDim.new(0, 4)
posLayout.Parent = posListFrame

local function refreshPositionList()
    for _, child in ipairs(posListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for name, cf in pairs(savedPositions) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.Parent = posListFrame

        local tpPosBtn = MakeButton("➡️ " .. name)
        tpPosBtn.Size = UDim2.new(0.8, -4, 1, 0)
        tpPosBtn.Parent = row

        tpPosBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = cf
            end
        end)

        local delBtn = MakeButton("X")
        delBtn.Size = UDim2.new(0.18, 0, 1, 0)
        delBtn.Position = UDim2.new(0.82, 4, 0, 0)
        delBtn.Parent = row

        delBtn.MouseButton1Click:Connect(function()
            savedPositions[name] = nil
            _G.shirayukimikoto_savedPositions = savedPositions
            refreshPositionList()
        end)
    end
end

saveBtn.MouseButton1Click:Connect(function()
    local name = saveNameBox.Text:match("%S+")
    if not name then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    savedPositions[name] = hrp.CFrame
    _G.shirayukimikoto_savedPositions = savedPositions
    refreshPositionList()
end)

local refreshBtn = addButton("🔄 Refresh List")
refreshBtn.MouseButton1Click:Connect(refreshPositionList)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshPositionList()
end)

refreshPositionList()
