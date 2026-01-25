-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Config
local WINDOW_NAME = "EmotePlusGUI"
local COLOR_PRIMARY = Color3.fromRGB(0, 85, 170)
local COLOR_BUTTON = Color3.fromRGB(0, 120, 215)
local COLOR_BG_DARK = Color3.fromRGB(30, 30, 60)
local COLOR_TEXT = Color3.new(1, 1, 1)

-- Helper: Safe parent to CoreGui or PlayerGui
local function safeParent(gui)
	local ok = pcall(function()
		gui.Parent = CoreGui
	end)
	if not ok or not gui.Parent then
		local pg = LocalPlayer:WaitForChild("PlayerGui")
		gui.Parent = pg
	end
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = WINDOW_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
safeParent(screenGui)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0, 50, 0, 150)
mainFrame.BackgroundColor3 = COLOR_PRIMARY
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false -- We'll handle dragging manually
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -56, 0, 36)
titleLabel.Position = UDim2.new(0, 8, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = COLOR_TEXT
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Text = "Emote+ Tools"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Minimize Button
local minimized = false
local savedSize = mainFrame.Size
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 28)
minimizeButton.Position = UDim2.new(1, -48, 0, 8)
minimizeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
minimizeButton.BorderSizePixel = 0
minimizeButton.TextColor3 = COLOR_TEXT
minimizeButton.Font = Enum.Font.GothamSemibold
minimizeButton.TextSize = 18
minimizeButton.Text = "—"
minimizeButton.Parent = mainFrame

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		mainFrame:TweenSize(UDim2.new(0, 320, 0, 52), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	else
		mainFrame:TweenSize(savedSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	end
end)

-- Dragging
local dragging = false
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

mainFrame.InputEnded:Connect(function(input)
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
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -60)
content.Position = UDim2.new(0, 8, 0, 52)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 6
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = content

-- Helper UI Makers
local function MakeLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = COLOR_TEXT
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = content
	return lbl
end

local function MakeTextBox(text)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(1, 0, 0, 32)
	tb.BackgroundColor3 = COLOR_BUTTON
	tb.TextColor3 = COLOR_TEXT
	tb.BorderSizePixel = 0
	tb.Text = text
	tb.ClearTextOnFocus = false
	tb.Font = Enum.Font.Gotham
	tb.TextSize = 14
	tb.Parent = content
	return tb
end

local function MakeButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = color or COLOR_BUTTON
	btn.TextColor3 = COLOR_TEXT
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = content
	return btn
end

-- ===== USER INFO =====
MakeLabel("👤 Player Info")
local userInfoLabel = MakeLabel("")
userInfoLabel.Text = string.format("Name: %s\nUserID: %d", LocalPlayer.Name, LocalPlayer.UserId)

-- ===== INSERT MODEL =====
MakeLabel("🧩 Insert Model (Client)")
local modelIdBox = MakeTextBox("Enter model ID")
local insertModelBtn = MakeButton("Insert Model", Color3.fromRGB(60, 180, 90))

insertModelBtn.MouseButton1Click:Connect(function()
	local idStr = modelIdBox.Text:match("%d+")
	if not idStr or idStr == "" then
		warn("Invalid model ID")
		return
	end

	local id = tonumber(idStr)
	if not id then return end

	task.spawn(function()
		local success, model = pcall(function()
			return game:GetObjects("rbxassetid://" .. id)[1]
		end)

		if success and model then
			model.Parent = workspace
			model:PivotTo(CFrame.new(workspace.Camera.CFrame.Position + Vector3.new(0, 5, 0)))
			warn("✅ Inserted model ID:", id)
		else
			warn("❌ Failed to load model ID:", id)
		end
	end)
end)

-- ===== EMOTE SYSTEM =====
MakeLabel("🎭 Emote System")

local emoteInput = MakeTextBox("Enter emote animation ID")
local emoteStatus = MakeLabel("")

local currentEmoteTrack = nil
local currentEmoteAnim = nil

local function stopEmote()
	if currentEmoteTrack then
		pcall(function() currentEmoteTrack:Stop() end)
		currentEmoteTrack = nil
	end
	if currentEmoteAnim then
		pcall(function() currentEmoteAnim:Destroy() end)
		currentEmoteAnim = nil
	end
	emoteStatus.Text = "⏹️ Emote stopped"
end

local function playEmote(idStr)
	if not idStr or idStr == "" then
		emoteStatus.Text = "❌ No ID"
		return
	end

	local idNum = tonumber(idStr)
	if not idNum then
		emoteStatus.Text = "❌ Invalid ID"
		return
	end

	local char = LocalPlayer.Character
	if not char then
		emoteStatus.Text = "❌ No character"
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		emoteStatus.Text = "❌ No humanoid"
		return
	end

	stopEmote()

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(idNum)
	anim.Parent = char
	currentEmoteAnim = anim

	local ok, track = pcall(function()
		return hum:LoadAnimation(anim)
	end)

	if ok and track then
		currentEmoteTrack = track
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		emoteStatus.Text = "▶️ Playing emote"
	else
		anim:Destroy()
		currentEmoteAnim = nil
		emoteStatus.Text = "❌ Load failed"
	end
end

-- Emote Buttons
local emoteBtns = Instance.new("Frame")
emoteBtns.Size = UDim2.new(1, 0, 0, 36)
emoteBtns.BackgroundTransparency = 1
emoteBtns.Parent = content

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48, -4, 1, 0)
startBtn.Position = UDim2.new(0, 0, 0, 0)
startBtn.BackgroundColor3 = COLOR_BUTTON
startBtn.TextColor3 = COLOR_TEXT
startBtn.Text = "▶️ Play"
startBtn.Parent = emoteBtns

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48, -4, 1, 0)
stopBtn.Position = UDim2.new(0.52, 0, 0, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
stopBtn.TextColor3 = COLOR_TEXT
stopBtn.Text = "⏹️ Stop"
stopBtn.Parent = emoteBtns

startBtn.MouseButton1Click:Connect(function()
	local id = emoteInput.Text:match("%d+")
	if id then
		playEmote(id)
	else
		emoteStatus.Text = "❌ Enter valid ID"
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	stopEmote()
end)

-- Saved Emote
MakeLabel("💾 Saved Emote")
local savedEmoteBox = MakeTextBox("")
local saveBtn = MakeButton("💾 Save", Color3.fromRGB(60, 180, 90))
local removeBtn = MakeButton("🗑️ Remove", Color3.fromRGB(180, 60, 60))

saveBtn.MouseButton1Click:Connect(function()
	local id = emoteInput.Text:match("%d+")
	if id then
		savedEmoteBox.Text = id
		emoteStatus.Text = "💾 Saved!"
	else
		emoteStatus.Text = "❌ Invalid ID"
	end
end)

removeBtn.MouseButton1Click:Connect(function()
	savedEmoteBox.Text = ""
	emoteStatus.Text = "🗑️ Cleared"
end)

-- Auto-play saved emote if double-clicked
savedEmoteBox.FocusLost:Connect(function(enterPressed)
	if enterPressed and savedEmoteBox.Text:match("%d+") then
		playEmote(savedEmoteBox.Text)
	end
end)

print("✅ Emote+ GUI loaded!")
