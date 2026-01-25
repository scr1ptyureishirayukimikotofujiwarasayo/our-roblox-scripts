-- ===== SIDE DODGE =====
local sideDodgeLabel = MakeLabel("Side Dodge (Q/E)")
sideDodgeLabel.Parent = content

local sideDodgeConn
local sideDodgeEnabled = false
local dodgeDuration = 0.15
local dodgeSpeed = 80

MakeToggle(content, "Side Dodge", function(on)
	sideDodgeEnabled = on

	if sideDodgeConn then
		sideDodgeConn:Disconnect()
		sideDodgeConn = nil
	end

	if on then
		sideDodgeConn = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

			local key = input.KeyCode
			if key ~= Enum.KeyCode.Q and key ~= Enum.KeyCode.E then return end

			local char = LocalPlayer.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
			if not hrp then return end

			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			local cam = workspace.CurrentCamera
			local right
			if cam then
				right = cam.CFrame.RightVector
			else
				right = hrp.CFrame.RightVector
			end

			local dir
			if key == Enum.KeyCode.E then
				dir = right
			else
				dir = Vector3.new(-right.X, -right.Y, -right.Z)
			end

			dir = Vector3.new(dir.X, 0, dir.Z)
			if dir.Magnitude == 0 then return end
			dir = dir.Unit

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			bv.Velocity = dir * dodgeSpeed
			bv.P = 1250
			bv.Parent = hrp

			local oldWs = hum.WalkSpeed
			if oldWs < dodgeSpeed then
				hum.WalkSpeed = dodgeSpeed
			end

			task.delay(dodgeDuration, function()
				if bv and bv.Parent then
					bv:Destroy()
				end
				if hum and hum.Parent then
					hum.WalkSpeed = oldWs
				end
			end)
		end)
	end
end)
