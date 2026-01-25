-- shirayukimikoto_anti_tp_player_tp_and_pos_saver.lua
-- Combined: Anti-Teleport + Teleport to Player + Position Saver
-- Requires: MakeLabel, MakeTextBox, MakeButton, content, LocalPlayer, Players, UserInputService, RunService, workspace, game

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== ANTI-TELEPORT =====
local antiTpConn
local lastPos

local antiTpLabel = MakeLabel("🛡️ Anti-Teleport")
antiTpLabel.Parent = content

local antiTpToggleBtn, getAntiTpState, setAntiTpState = MakeToggle(content, "AntiTeleport", function(on)
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

-- ===== TELEPORT TO PLAYER =====
local tpLabel = MakeLabel("👤 Teleport to Player")
tpLabel.Parent = content

local tpInput = MakeTextBox("Type username")
tpInput.Parent = content

local tpButtonsFrame = Instance.new("Frame")
tpButtonsFrame.Size = UDim2.new(1, 0, 0, 36)
tpButtonsFrame.BackgroundTransparency = 1
tpButtonsFrame.Parent = content

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0.48, -4, 1, 0)
tpButton.Position = UDim2.new(0, 0, 0, 0)
tpButton.BackgroundColor3 = Color3.fromRGB(60, 180, 90)
tpButton.TextColor3 = Color3.new(1, 1, 1)
tpButton.Font = Enum.Font.Gotham
tpButton.TextSize = 14
tpButton.Text = "Teleport"
tpButton.Parent = tpButtonsFrame

local tpClosestButton = Instance.new("TextButton")
tpClosestButton.Size = UDim2.new(0.48, -4, 1, 0)
tpClosestButton.Position = UDim2.new(0.52, 0, 0, 0)
tpClosestButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
tpClosestButton.TextColor3 = Color3.new(1, 1, 1)
tpClosestButton.Font = Enum.Font.Gotham
tpClosestButton.TextSize = 14
tpClosestButton.Text = "TP Closest"
tpClosestButton.Parent = tpButtonsFrame

local function findMatchingPlayers(partial)
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

local function teleportToPlayer(plr)
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local targetChar = plr.Character
	if not targetChar then return end

	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	hrp.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
end

tpButton.MouseButton1Click:Connect(function()
	local text = tpInput.Text:match("%S+") or ""
	if text == "" then return end

	local matches = findMatchingPlayers(text)
	if #matches >= 1 then
		teleportToPlayer(matches[1])
	end
end)

tpClosestButton.MouseButton1Click:Connect(function()
	local text = tpInput.Text:match("%S+") or ""
	if text == "" then return end

	local matches = findMatchingPlayers(text)
	if #matches == 0 then return end

	local char = LocalPlayer.Character
	if not char then
		teleportToPlayer(matches[1])
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		teleportToPlayer(matches[1])
		return
	end

	local closestPlr = nil
	local closestDist = math.huge
	for _, plr in ipairs(matches) do
		local tChar = plr.Character
		if tChar then
			local tRoot = tChar:FindFirstChild("HumanoidRootPart")
			if tRoot then
				local dist = (tRoot.Position - hrp.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlr = plr
				end
			end
		end
	end

	if closestPlr then
		teleportToPlayer(closestPlr)
	end
end)

-- ===== POSITION SAVER & TELEPORTER =====
local savedPositions = {} -- { name = CFrame, ... }

-- Load from _G or persistent storage (optional)
if _G.shirayukimikoto_savedPositions then
	savedPositions = _G.shirayukimikoto_savedPositions
else
	_G.shirayukimikoto_savedPositions = savedPositions
end

local posLabel = MakeLabel("📍 Position Saver")
posLabel.Parent = content

-- Save current position
local savePosNameBox = MakeTextBox("Position name")
savePosNameBox.Parent = content

local savePosBtn = MakeButton("Save Current Position")
savePosBtn.Parent = content

savePosBtn.MouseButton1Click:Connect(function()
	local name = savePosNameBox.Text:match("%S+")
	if not name then
		warn("Enter a valid name")
		return
	end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	savedPositions[name] = hrp.CFrame
	_G.shirayukimikoto_savedPositions = savedPositions
	warn("Saved position:", name)
end)

-- Teleport to saved position
local tpToSelector = Instance.new("TextLabel")
tpToSelector.Size = UDim2.new(1, 0, 0, 24)
tpToSelector.BackgroundTransparency = 1
tpToSelector.TextColor3 = Color3.new(1, 1, 1)
tpToSelector.Font = Enum.Font.Gotham
tpToSelector.TextSize = 14
tpToSelector.Text = "Select position to teleport:"
tpToSelector.Parent = content

local tpToDropdown = Instance.new("ScrollingFrame")
tpToDropdown.Size = UDim2.new(1, 0, 0, 120)
tpToDropdown.BackgroundTransparency = 1
tpToDropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
tpToDropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpToDropdown.ScrollBarThickness = 4
tpToDropdown.Parent = content

local function refreshPositionList()
	-- Clear old buttons
	for _, child in ipairs(tpToDropdown:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Add buttons for each saved position
	for name, cf in pairs(savedPositions) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 28)
		btn.Position = UDim2.new(0, 4, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.Text = "➡️ " .. name
		btn.Parent = tpToDropdown

		btn.MouseButton1Click:Connect(function()
			local char = LocalPlayer.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = cf
			end
		end)

		-- Delete button
		local delBtn = Instance.new("TextButton")
		delBtn.Size = UDim2.new(0, 20, 0, 20)
		delBtn.Position = UDim2.new(1, -24, 0, 4)
		delBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
		delBtn.TextColor3 = Color3.new(1, 1, 1)
		delBtn.Font = Enum.Font.GothamBold
		delBtn.TextSize = 14
		delBtn.Text = "X"
		delBtn.Parent = btn

		delBtn.MouseButton1Click:Connect(function()
			savedPositions[name] = nil
			_G.shirayukimikoto_savedPositions = savedPositions
			btn:Destroy()
		end)
	end
end

refreshPositionList()

-- Refresh button
local refreshBtn = MakeButton("🔄 Refresh List")
refreshBtn.Parent = content
refreshBtn.MouseButton1Click:Connect(refreshPositionList)

-- Auto-refresh on character respawn
local charAddedConn
charAddedConn = LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	refreshPositionList()
end)

-- Optional: Clean up on script end (not usually needed in exploits)
