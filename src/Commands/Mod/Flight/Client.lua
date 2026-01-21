--!strict
-- CONFIG
local DIRECTIONS = {
	Left = Vector3.new(-1, 0, 0);
	Right = Vector3.new(1, 0, 0);
	Forwards = Vector3.new(0, 0, -1);
	Backwards = Vector3.new(0, 0, 1);
	Up = Vector3.new(0, 1, 0);
	Down = Vector3.new(0, -1, 0);
}


-- LOCAL
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHRP = require(modules.PlayerUtil.getHRP)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local activeCollisionGroups = {}
local inputControllerModule = modules.Parent.Controllers.InputController


-- TYPES
type LockType = "PlatformStand" | "Sit"


-- LOCAL FUNCTIONS
local function setCollisionGroupRecursive(object: Instance, groupName: string?)
	if groupName and not activeCollisionGroups[groupName] then
		-- We don't create the collision group until needed to
		-- minimise startup performance impact
		activeCollisionGroups[groupName] = true
		pcall(function()
			PhysicsService:RegisterCollisionGroup(groupName)
		end)
	end
	for _, instance: Instance in object:GetDescendants() do
		if not instance:IsA("BasePart") then
			continue
		end
		local count = instance:GetAttribute("HDCollisionGroupCount") :: number or 0
		local originalGroup = instance:GetAttribute("HDOriginalCollisionGroup")
		if groupName then
			if not originalGroup then
				instance:SetAttribute("HDOriginalCollisionGroup", instance.CollisionGroup)
			end
			count += 1
			instance.CollisionGroup = groupName
		elseif typeof(originalGroup) == "string" then
			count -= 1
			if count <= 0 then
				count = nil
			end
			instance.CollisionGroup = originalGroup
		end
		instance:SetAttribute("HDCollisionGroupCount", count)
	end
end

local function getCF(part, isFor)
	--Credit to @Sceleratis for this
	local cframe = part.CFrame
	local noRot = CFrame.new(cframe.p)
	local x, y, z = (workspace.CurrentCamera.CFrame - workspace.CurrentCamera.CFrame.p):toEulerAnglesXYZ()
	return noRot * CFrame.Angles(isFor and z or x, y, z)
end

local function getNextMovement(deltaTime: number, speed: number)
	local nextMove = Vector3.new()
	local InputController = require(inputControllerModule)
	local pressedMovementKeys = InputController.getPressedMovementKeys()
	local function updateNextMove()
		if UserInputService.KeyboardEnabled then
			for i,v in pressedMovementKeys do
				local vector = DIRECTIONS[v]
				if not vector then
					continue
				end
				nextMove = nextMove + vector
			end
			return
		end
		local humanoid = getHumanoid()
		local hrp = getHRP()
		if not humanoid or not hrp then
			return
		end
		local md = humanoid.MoveDirection
		local md = humanoid.MoveDirection
		for i,v in DIRECTIONS do
			local isFor = false
			if i == "Forwards" or i == "Backwards" then
				isFor = true
			end
			local vector = ((getCF(hrp, true)*CFrame.new(v)) - hrp.CFrame.p).p;
			if (vector - md).magnitude <= 1.05 and md ~= Vector3.new(0,0,0) then
				nextMove = nextMove + v
			end
		end
		return
	end
	updateNextMove()
	return CFrame.new(nextMove * speed * deltaTime), nextMove
end

local function handleInput(task: Task.Class, callback: any)
	local InputController = require(inputControllerModule)
	local Janitor = require(modules.Objects.Janitor)
	local taskJanitor = task.janitor
	local flightJanitor = taskJanitor:add(Janitor.new())
	local humanoid = getHumanoid()
	local function toggleFlight()
		local isActive = not task.extra.isActive
		task.extra.isActive = isActive
		if not isActive then
			flightJanitor:cleanup()
		else
			task.spawn(callback)
		end
	end
	task.extra.janitor = flightJanitor
	task.extra.isActive = true
	task:onEnded(function()
		task.extra.isActive = false
	end)
	task.spawn(callback)
	taskJanitor:add(InputController.onPressed(Enum.KeyCode.E, toggleFlight))
	if humanoid then
		taskJanitor:add(InputController.onDoubleJumped(humanoid, toggleFlight))
	end
end

local function startFlight(task: Task.Class, startSpeed: number, lockType: LockType, noclip: boolean)
	local hrp = getHRP()
	local humanoid = getHumanoid() :: any
	if not hrp or not humanoid then
		return
	end

	local janitor = task.extra.janitor
	local flyForce = janitor:add(Instance.new("BodyPosition"))
	flyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyForce.Position = hrp.Position + Vector3.new(0,4,0)
	flyForce.Name = "HDAdminFlyForce"
	flyForce.Parent = hrp

	local bodyGyro = janitor:add(Instance.new("BodyGyro"))
	bodyGyro.D = 50
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	if noclip then
		bodyGyro.P = 2000
	else
		bodyGyro.P = 200
	end
	bodyGyro.Name = "HDAdminFlyGyro"
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	local char = localPlayer.Character
	if noclip and char then
		setCollisionGroupRecursive(workspace, "HDGroupWorkspace")
		setCollisionGroupRecursive(char, "HDGroupCharacter")
	end

	task.extra.speed = startSpeed

	local tiltMax = 25
	local tiltAmount = 0
	local tiltInc = 1
	local static = 0
	local lastUpdate = tick()
	local lastPosition = hrp.Position
	repeat
		local delta = tick()-lastUpdate
		local look = (camera.Focus.p-camera.CFrame.p).unit
		local speed = task.extra.speed
		local move, directionalVector = getNextMovement(delta, speed*10)
		local pos = hrp.Position
		local targetCFrame = CFrame.new(pos,pos+look) * move
		local targetD = 750 + (speed*0.2)
		if noclip then
			targetD = targetD/2
		end
		if move.p ~= Vector3.new() then
			static = 0
			flyForce.D = targetD
			tiltAmount = tiltAmount + tiltInc
			flyForce.Position = targetCFrame.p
		else
			static = static + 1
			tiltAmount = 1
			local maxMag = 6
			local mag = (hrp.Position - lastPosition).magnitude
			if mag > maxMag and static >= 4 then
				flyForce.Position = hrp.Position
			end
		end
		if math.abs(tiltAmount) > tiltMax then
			tiltAmount = tiltMax
		end
		if flyForce.D == targetD then
			local tiltX = tiltAmount * directionalVector.X * -0.5
			local tiltZ = (noclip and 0) or tiltAmount * directionalVector.Z
			bodyGyro.CFrame = targetCFrame * CFrame.Angles(math.rad(tiltZ), 0, 0)
		end
		lastUpdate = tick()
		lastPosition = hrp.Position
		humanoid[lockType] = true
		task.wait()
	until not task.extra.isActive or not humanoid or not hrp
	flyForce:Destroy()
	bodyGyro:Destroy()
	if humanoid then
		humanoid[lockType] = false
	end
	if noclip then
		setCollisionGroupRecursive(workspace, nil)
		if char and char.Parent then
			setCollisionGroupRecursive(char, nil)
		end
	end
end


-- COMMANDS
local clientCommands: Task.ClientCommands = {

	--------------------
	{
		name = "Fly",
		run = function(task: Task.Class, speed: number)
			handleInput(task, function()
				startFlight(task, speed, "PlatformStand", false)
			end)
		end,
	},

	--------------------
	{
		name = "Fly2",
		run = function(task: Task.Class, speed: number)
			handleInput(task, function()
				startFlight(task, speed, "Sit", false)
			end)
		end,
	},

	--------------------
	{
		name = "NoClip",
		run = function(task: Task.Class, speed: number)
			handleInput(task, function()
				local humanoid = getHumanoid()
				local hrp = getHRP()
				if not humanoid or not hrp then
					return
				end
				local lastUpdate = tick()
				task.extra.speed = speed
				hrp.Anchored = true
				humanoid.PlatformStand = true
				repeat
					local delta = tick()-lastUpdate
					local look = (camera.Focus.Position-camera.CFrame.Position).Unit
					local move = getNextMovement(delta, task.extra.speed)
					local pos = hrp.Position
					hrp.CFrame = CFrame.new(pos,pos+look) * move
					lastUpdate = tick()
					task.wait()
				until not task.extra.isActive
				if hrp and humanoid then
					hrp.Anchored = false
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					humanoid.PlatformStand = false
				end
			end)
		end,
	},

	--------------------
	{
		name = "NoClip2",
		run = function(task: Task.Class, speed: number)
			handleInput(task, function()
				startFlight(task, speed, "Sit", true)
			end)
		end,
	},

	--------------------
}


return clientCommands