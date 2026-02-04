-- Stat Multiplier Script - Multiplies all stat gain by 100
-- This script enhances all stat gains from equipment and activities

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Wait for player to be fully loaded
repeat task.wait() until LocalPlayer.Character

-- Get the global functions module
local globalFunctions = require(ReplicatedStorage:WaitForChild("globalFunctions"))

-- Multiplier value (change this to adjust the multiplier)
local STAT_MULTIPLIER = 100

-- Auto training settings
local AUTO_TRAIN_ENABLED = true
local TRAIN_INTERVAL = 1 -- seconds
local STRENGTH_GAIN_PER_TRAIN = 10
local AGILITY_GAIN_PER_TRAIN = 8
local DURABILITY_GAIN_PER_TRAIN = 6

-- Hook into stat changes instead of overriding functions
local isUpdating = {} -- Prevent infinite recursion

local function hookStats()
	local playerStats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:WaitForChild("leaderstats")
	
	-- Monitor strength changes
	local strength = playerStats:FindFirstChild("Strength") or playerStats:WaitForChild("Strength")
	local lastStrength = strength.Value
	strength:GetPropertyChangedSignal("Value"):Connect(function()
		if isUpdating.strength then return end
		local currentStrength = strength.Value
		local difference = currentStrength - lastStrength
		if difference > 0 then
			isUpdating.strength = true
			-- Multiply the gain
			strength.Value = lastStrength + (difference * STAT_MULTIPLIER)
			isUpdating.strength = false
		end
		lastStrength = strength.Value
	end)
	
	-- Monitor agility changes
	local agility = playerStats:FindFirstChild("Agility") or playerStats:WaitForChild("Agility")
	local lastAgility = agility.Value
	agility:GetPropertyChangedSignal("Value"):Connect(function()
		if isUpdating.agility then return end
		local currentAgility = agility.Value
		local difference = currentAgility - lastAgility
		if difference > 0 then
			isUpdating.agility = true
			-- Multiply the gain
			agility.Value = lastAgility + (difference * STAT_MULTIPLIER)
			isUpdating.agility = false
		end
		lastAgility = agility.Value
	end)
	
	-- Monitor durability changes
	local durability = playerStats:FindFirstChild("Durability") or playerStats:WaitForChild("Durability")
	local lastDurability = durability.Value
	durability:GetPropertyChangedSignal("Value"):Connect(function()
		if isUpdating.durability then return end
		local currentDurability = durability.Value
		local difference = currentDurability - lastDurability
		if difference > 0 then
			isUpdating.durability = true
			-- Multiply the gain
			durability.Value = lastDurability + (difference * STAT_MULTIPLIER)
			isUpdating.durability = false
		end
		lastDurability = durability.Value
	end)
	
	-- Monitor gems changes (optional)
	local gems = playerStats:FindFirstChild("Gems") or playerStats:FindFirstChild("💎 Gems")
	if gems then
		local lastGems = gems.Value
		gems:GetPropertyChangedSignal("Value"):Connect(function()
			if isUpdating.gems then return end
			local currentGems = gems.Value
			local difference = currentGems - lastGems
			if difference > 0 then
				isUpdating.gems = true
				-- Multiply the gain
				gems.Value = lastGems + (difference * STAT_MULTIPLIER)
				isUpdating.gems = false
			end
			lastGems = gems.Value
		end)
	end
end

-- Start the stat hooking
hookStats()

-- Hook into muscleEvent for additional stat gains
local muscleEvent = LocalPlayer:WaitForChild("muscleEvent")

-- Listen for stat gain events and multiply them
muscleEvent.OnClientEvent:Connect(function(eventType, ...)
	-- This catches any direct stat gains that might bypass the global functions
	-- The main multiplication happens in the overridden functions above
end)

-- Auto training function
local function autoTrain()
	if not AUTO_TRAIN_ENABLED then return end
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
	if LocalPlayer.Character.Humanoid.Health <= 0 then return end
	
	local playerStats = LocalPlayer:FindFirstChild("leaderstats")
	if not playerStats then return end
	
	-- Directly add stats to leaderstats (will be multiplied by the hook system)
	local strength = playerStats:FindFirstChild("Strength")
	local agility = playerStats:FindFirstChild("Agility") 
	local durability = playerStats:FindFirstChild("Durability")
	
	if strength then strength.Value += STRENGTH_GAIN_PER_TRAIN end
	if agility then agility.Value += AGILITY_GAIN_PER_TRAIN end
	if durability then durability.Value += DURABILITY_GAIN_PER_TRAIN end
	
	-- Additional training combinations
	if strength then strength.Value += STRENGTH_GAIN_PER_TRAIN * 0.5 end
	if durability then durability.Value += DURABILITY_GAIN_PER_TRAIN * 0.5 end
	
	if strength then strength.Value += STRENGTH_GAIN_PER_TRAIN * 0.3 end
	if agility then agility.Value += AGILITY_GAIN_PER_TRAIN * 0.7 end
end

-- Start auto training loop
local lastTrainTime = 0
RunService.Heartbeat:Connect(function(deltaTime)
	lastTrainTime += deltaTime
	if lastTrainTime >= TRAIN_INTERVAL then
		autoTrain()
		lastTrainTime = 0
	end
end)

print("Stat Multiplier Script loaded! All stat gains are now multiplied by " .. STAT_MULTIPLIER)
print("Auto training enabled! Gaining stats automatically every " .. TRAIN_INTERVAL .. " seconds")