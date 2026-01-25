--========================================================--
--  TELEPORT TOOLS (CLEAN, MODULAR, MULTI-SAVE VERSION)   --
--========================================================--

-- Shortcuts
local Players = Players
local LocalPlayer = LocalPlayer
local UserInputService = UserInputService
local RunService = RunService

--========================================================--
-- 1. ANTI-TELEPORT
--========================================================--

MakeLabel("🛡️ Anti-Teleport").Parent = tpSection

local antiTpConn
local lastPos

MakeToggle(tpSection, "AntiTeleport", function(on)
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

--========================================================--
-- 2. TELEPORT TO PLAYER
--========================================================--

MakeLabel("👤 Teleport to Player").Parent = tpSection

local tpInput = MakeTextBox("Type username")
tpInput.Parent = tpSection

local tpRow = Instance.new("Frame")
tpRow.Size = UDim2.new(1, 0, 0, 32)
tpRow.BackgroundTransparency = 1
tpRow.Parent = tpSection

local tpBtn = MakeButton("Teleport")
tpBtn.Size = UDim2.new(0.48, -4, 1, 0)
tpBtn.Parent = tpRow

local tpClosestBtn = MakeButton("TP Closest")
tpClosestBtn.Size = UDim2.new(0.48, -4, 1, 0)
tpClosestBtn.Position = UDim2.new(0.52, 0, 0, 0)
tpClosestBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
tpClosestBtn.Parent = tpRow

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

--========================================================--
-- 3. POSITION SAVER
--========================================================--

MakeLabel("📍 Position Saver").Parent = tpSection

local saveNameBox = MakeTextBox("Position name")
saveNameBox.Parent = tpSection

local saveBtn = MakeButton("Save Current Position")
saveBtn.Parent = tpSection

local savedPositions = _G.shirayukimikoto_savedPositions or {}
_G.shirayukimikoto_savedPositions = savedPositions

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

--========================================================--
-- 4. SAVED POSITIONS LIST
--========================================================--

MakeLabel("Saved Positions").Parent = tpSection

local posList = Instance.new("ScrollingFrame")
posList.Size = UDim2.new(1, 0, 0, 140)
posList.BackgroundTransparency = 1
posList.CanvasSize = UDim2.new(0, 0, 0, 0)
posList.AutomaticCanvasSize = Enum.AutomaticSize.Y
posList.ScrollBarThickness = 4
posList.Parent = tpSection

local posLayout = Instance.new("UIListLayout")
posLayout.FillDirection = Enum.FillDirection.Vertical
posLayout.SortOrder = Enum.SortOrder.LayoutOrder
posLayout.Padding = UDim.new(0, 4)
posLayout.Parent = posList

function refreshPositionList()
    for _, child in ipairs(posList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for name, cf in pairs(savedPositions) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 28)
        row.BackgroundTransparency = 1
        row.Parent = posList

        local tpBtn = MakeButton("➡️ " .. name)
        tpBtn.Size = UDim2.new(0.8, -4, 1, 0)
        tpBtn.Parent = row

        tpBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = cf end
        end)

        local delBtn = MakeButton("X")
        delBtn.Size = UDim2.new(0.18, 0, 1, 0)
        delBtn.Position = UDim2.new(0.82, 4, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        delBtn.Parent = row

        delBtn.MouseButton1Click:Connect(function()
            savedPositions[name] = nil
            _G.shirayukimikoto_savedPositions = savedPositions
            refreshPositionList()
        end)
    end
end

refreshPositionList()

--========================================================--
-- 5. REFRESH BUTTON
--========================================================--

local refreshBtn = MakeButton("🔄 Refresh List")
refreshBtn.Parent = tpSection
refreshBtn.MouseButton1Click:Connect(refreshPositionList)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshPositionList()
end)
