--!strict
-- LOCAL
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local func = require(script.Parent.Parent.Parent.Parent.Packages[".pesde"]["csqrl_sift@0.0.9"].sift.Util.func)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHead = require(modules.PlayerUtil.getHead)
local getHRP = require(modules.PlayerUtil.getHRP)
local getNeck = require(modules.PlayerUtil.getNeck)
local lasersActive = {}
local originalNecks = {}
local laserTweenTime = 0.7
local laserTweenInfo = TweenInfo.new(laserTweenTime)


-- LOCAL FUNCTIONS
local function displayLaser(targetHandle, status)
	local leftBeam = targetHandle and targetHandle:FindFirstChild("LeftBeam")
	if leftBeam then
		leftBeam.Enabled = status
		targetHandle.RightBeam.Enabled = status
		targetHandle.MidAttachment.GlowHit.Enabled = status
	end
end


-- CLIENT COMMANDS
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "Ice",
		run = function(task: Task.Class, iceBlock, hrp)
			if iceBlock and hrp then
				iceBlock.CFrame = hrp.CFrame * CFrame.new(0, 0.8, 0)
			end
		end,
	},

	--------------------
	{
		name = "LaserEyes",
		run = function(task: Task.Class, laserTarget)
			local inputController = modules.Parent.Controllers.InputController
			local InputController = require(modules.Parent.Controllers.InputController)
			task.janitor:add(InputController.pressed:Connect(function()
				
				-- Make sure we only start this once
				if task.extra.isRunning then
					return
				end
				task.extra.isRunning = true

				-- Check body parts and instances exist
				local head = getHead()
				local humanoid = getHumanoid()
				local hrp = getHRP()
				local neck = getNeck()
				if not head or not humanoid or not hrp or not neck then
					return
				end
				local char = head.Parent :: Model?
				if not laserTarget or not char then
					return
				end
				
				-- We must set the primary part of the char to the HRP for accurate
				-- behaviour accross R6 and R15
				local isR6 = humanoid.RigType == Enum.HumanoidRigType.R6
				char.PrimaryPart = hrp
				
				-- Record values
				local targetHandle = laserTarget
				local maxDistance = 30
				local lastUpdate = tick()-1
				local originalC0 = neck.C0
				local primaryPart = char.PrimaryPart
				local additionalY =  0--(head.Position.Y - head.Size.Y/2 - primaryPart.Position.Y)
				local originalNeckY = neck.C0.Position.Y
				local completedOffset = false
				local fire = targetHandle.MidAttachment2.Fire
				local sparks = targetHandle.MidAttachment.Sparks
				local localPlayer = Players.LocalPlayer

				-- Play sizzles and show laser
				local sizzle = script.LaserSizzle1
				local sizzle2 = script.LaserSizzle2
				sizzle:Play()
				displayLaser(targetHandle, true)
				
				repeat
					local position, hit = InputController.getHitPoint()
					local targetCFrame = CFrame.new(position, head.Position)
					local distanceFromPlayer = localPlayer:DistanceFromCharacter(targetCFrame.Position)
					local exceededMaxDistance = false
					if distanceFromPlayer > maxDistance then
						targetCFrame = targetCFrame * CFrame.new(0, 0, maxDistance-distanceFromPlayer)
						exceededMaxDistance = true
					end
					targetHandle.CFrame = targetCFrame
					local headPos = head.Position
					local targetPos = targetHandle.Position
					local direction = (Vector3.new(targetPos.X, headPos.Y, targetPos.Z) - head.Position).Unit
					if char.PrimaryPart == nil then
						char.PrimaryPart = hrp
					end
					primaryPart = primaryPart :: BasePart
					local targetDirection = (primaryPart.CFrame):VectorToObjectSpace(direction)
					local lookCFrame = (CFrame.new(Vector3.new(), targetDirection))
					if isR6 then
						lookCFrame = lookCFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(180),0)
					else
						lookCFrame = lookCFrame * CFrame.new(0,additionalY,0)
					end
					if not completedOffset then
						completedOffset = true
						local difference = lookCFrame.Position.Y - originalNeckY
						additionalY -= difference
						lookCFrame *= CFrame.new(0,additionalY,0)
					end
					neck.C0 = lookCFrame
					if tick() - 0.6 > lastUpdate then
						lastUpdate = tick()
						task.server:replicate(targetCFrame, lookCFrame)
					end
					local hitParent = hit and hit.Parent
					local hitName = hit and hit.Name
					if not exceededMaxDistance and hitParent and (hitParent:FindFirstChild("Humanoid") or hitName == "Handle") then
						fire.Enabled = true
						sparks.Enabled = true
						if not sizzle2.Playing then
							sizzle2:Play()
						end
					else
						fire.Enabled = false
						sparks.Enabled = false
						if sizzle2.Playing then
							sizzle2:Stop()
						end
					end
					wait()
					
				until not InputController.isPressing() or not task.isActive or not head.Parent or not neck.Parent
				neck.C0 = originalC0
				displayLaser(targetHandle, false)
				fire.Enabled = false
				sparks.Enabled = false
				sizzle:Stop()
				sizzle2:Stop()
				task.extra.isRunning = nil

			end))
		end,

		replication = function(target: Player, laserTarget: BasePart, targetCFrame: CFrame, lookCFrame: CFrame)
			local head = getHead(target)
			local neck = getNeck(target)
			if not head or not neck then
				return
			end
			if not laserTarget then
				return
			end
			local char = head.Parent :: Model
			local targetHandle = laserTarget :: any
			if lasersActive[target] then -- --Laser is already active
				lasersActive[target] = lasersActive[target] + 1
			else -- New laser
				lasersActive[target] = 1
				originalNecks[target] = neck.C0
				local randomZ = math.random(10,40) - 15
				targetHandle.CFrame = targetCFrame * CFrame.new(0, 0, randomZ)
				neck.C0 = lookCFrame
				targetHandle.MidAttachment.GlowHit.Rate = 50
				displayLaser(targetHandle, true)
			end
			TweenService:Create(targetHandle, laserTweenInfo, {CFrame = targetCFrame}):Play()
			TweenService:Create(neck, laserTweenInfo, {C0 = lookCFrame}):Play()
			task.wait(laserTweenTime)
			lasersActive[target] = lasersActive[target] - 1
			if lasersActive[target] <= 0 then
				displayLaser(targetHandle, false)
				local resetCFrame = originalNecks[target]
				neck.C0 = resetCFrame
				task.delay(0.1, function()
					neck.C0 = resetCFrame
				end)
				originalNecks[target] = nil
				lasersActive[target] = nil
			end
		end,
	},

	--------------------
}
return clientCommands