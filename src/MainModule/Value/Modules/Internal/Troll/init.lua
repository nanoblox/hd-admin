--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHead = require(modules.PlayerUtil.getHead)
local getHRP = require(modules.PlayerUtil.getHRP)
local getTargets = require(modules.CommandUtil.getTargets)
local commands: Task.Commands = {

    --------------------
	{
		name = "Ice",
		undoAliases = {"Thaw"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
			-- Keep the task alive even if the player resets
			task:keep("UntilTargetLeaves")

			-- Setup items
			local target = unpack(args)
			local iceBlock = task.janitor:add(script.IceBlock:Clone())
			local setAnchored = require(modules.AssetUtil.setAnchored)
			local applyDescription = require(modules.OutfitUtil.applyDescription)
			local getDescription = require(modules.OutfitUtil.getDescription)
			local hrp, humanoid
			local dynamicHeads = {132855169242647, 92366739937004, 15046070721, 139399623574323, 18731068680, 98817764899949}
			local originalHeadId = nil
			local selectedHeadId: number? = nil
			local fixedCFrame: CFrame? = nil
			local function updateBlock()
				if hrp then
					iceBlock.CFrame = hrp.CFrame * CFrame.new(0, 0.8, 0)
					task.client:runAll(iceBlock, hrp)
				end
			end

			-- Not all objects get replicated to the client (e.g. Streaming Radius)
			-- so we must forcefully expose the instance to the client
			iceBlock.Parent = workspace
			task.client:expose(target, iceBlock)
			updateBlock()
			
			-- This re-applies the head additionally when the player respawns or their outfit changes
			task:buff(target, "Outfit", function(hasEnded, originalValue: any)
				humanoid = getHumanoid(target)
				hrp = getHRP(target)
				if not hrp or not humanoid then return end
				local char = target.Character
				local originalDescription = (originalValue or getDescription(humanoid)) :: any
				selectedHeadId = selectedHeadId or dynamicHeads[math.random(1,#dynamicHeads)] :: number
				if not fixedCFrame then
					fixedCFrame = hrp.CFrame
				end
				hrp.CFrame = fixedCFrame :: any
				if hasEnded then
					setAnchored(char, false)
					applyDescription(humanoid, originalDescription)
				else
					setAnchored(char, true)
					applyDescription(humanoid, originalValue, {
						Head = selectedHeadId
					})
					task.delay(0.1, function()
						updateBlock()
					end)
				end
				return originalDescription
			end)
			
		end
	},

    --------------------
	{
		name = "Jail",
		aliases	= {"JailCell","JC"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local jailCell = task.janitor:add(script.JailCell:Clone())
			local head = getHead(target)
			local function moveIntoJail()
				head = getHead(target)
				if head then
					head.CFrame = jailCell.Union.CFrame
				end
			end
			local primaryPart = jailCell.Union
			jailCell.PrimaryPart = primaryPart
			if head then
				jailCell:PivotTo(head.CFrame * CFrame.new(0,-0.2,0))
			end
			jailCell.Parent = workspace
			task:keep("UntilTargetLeaves")
			task:redo(target, moveIntoJail)
		end
	},

    --------------------
	{
		name = "LaserEyes",
		aliases	= {"LE", "LazerEyes", "LasorEyes", "LazorEyes"};
		args = {"Player", "Color"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local color = task:getOriginalArg("Color") :: Color3 or Color3.fromRGB(255, 0, 0)
			local promptPurchaseAsync = require(modules.AssetUtil.promptPurchaseAsync)
			local ownsAssetAsync = require(modules.AssetUtil.ownsAssetAsync)
			if not(ownsAssetAsync("LaserEyes", target) or ownsAssetAsync("OldDonor", target)) then
				task.defer(function()
					promptPurchaseAsync("LaserEyes", target)
				end)
				return
			end
			local humanoid = getHumanoid(target)
			if not humanoid then return end
			local char = target.Character
			local laserGroup = task.janitor:add(script.LaserGroup:Clone())
			local laserTarget = task.janitor:add(laserGroup.HDLaserTarget)
			local leftEye = laserGroup.HDLeftEye
			local rightEye = laserGroup.HDRightEye
			
			laserTarget.Parent = char
			task:keep("UntilTargetRespawns")
			task.client:expose(target, laserTarget)
			task.client:run(target, laserTarget)
			task.client.replicator = function(replicateTo, targetCFrame, lookCFrame)
				if typeof(targetCFrame) ~= "CFrame" or typeof(lookCFrame) ~= "CFrame" then
					return
				end
				local getTargets = require(modules.CommandUtil.getTargets)
				for _, player in getTargets("OthersNearby", target, 100) do
					replicateTo(player, target, laserTarget, targetCFrame, lookCFrame)
				end
			end

			for _, instance in laserTarget:GetDescendants() do
				if instance:IsA("Beam") then
					instance.Color = ColorSequence.new(color)
				end
			end
			for _, instance in leftEye:GetDescendants() do
				if instance:IsA("Part") then
					instance.Color = color
				end
			end
			for _, instance in rightEye:GetDescendants() do
				if instance:IsA("Part") then
					instance.Color = color
				end
			end
			for _, instance in laserGroup:GetChildren() do
				if instance:IsA("Accessory") then
					task.janitor:add(instance)
					humanoid:AddAccessory(instance)
				end
			end

			local tweenTime = 2
			task:tween(leftEye.Handle, TweenInfo.new(tweenTime), {Transparency = 0})
			task:tween(rightEye.Handle, TweenInfo.new(tweenTime), {Transparency = 0})
		end
	},

    --------------------
	{
		name = "Explode",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local hrp = getHRP(target)
			if not hrp then return end
			local char = target.Character
			local explosion = Instance.new("Explosion")
			explosion.Position = hrp.Position
			explosion.Parent = char
			explosion.DestroyJointRadiusPercent = 0
			char:BreakJoints()
		end
	},

    --------------------
	{
		name = "Fling",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local targetHRP = getHRP(target)
			local targetHumanoid = getHumanoid(target)
			local caller = task.caller
			local callerHRP = getHRP(caller)
			if not targetHRP or not targetHumanoid or not callerHRP then
				return
			end
			local flingDistance = 50--math.random(14,20)
			local callerPos = callerHRP.Position
			local targetPos = targetHRP.Position
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.MaxForce = Vector3.new(10000000, 10000000, 10000000)
			bodyPosition.Name = "HDAdminFlingBP"
			bodyPosition.D = 450
			bodyPosition.P = 10000
			if target == caller then
				targetPos = (targetHRP.CFrame * CFrame.new(0,0,-4)).Position
			end
			local direction = (targetPos - callerPos).Unit
			bodyPosition.Position = targetPos + Vector3.new(direction.X, 1.4, direction.Z) * flingDistance
			local spin = Instance.new("BodyAngularVelocity")
			spin.MaxTorque = Vector3.new(300000, 300000, 300000)
			spin.P = 300
			spin.AngularVelocity = Vector3.new(10, 10 ,10)
			spin.Name = "HDAdminFlingSpin"
			spin.Parent = targetHRP
			local Debris = game:GetService("Debris")
			Debris:AddItem(spin, 0.1)
			bodyPosition.Parent = targetHRP
			Debris:AddItem(bodyPosition, 0.1)
			targetHumanoid.PlatformStand = true
			task.wait(5)
			targetHumanoid.PlatformStand = false
		end
	},

    --------------------
	
}
return commands