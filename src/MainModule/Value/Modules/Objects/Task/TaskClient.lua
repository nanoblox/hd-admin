-- LOCAL
--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local getTargets = require(modules.PlayerUtil.getTargets)
local Remote = require(modules.Objects.Remote)
local RunService = game:GetService("RunService")
local runClientCommand: Remote.Class? = nil
local requestReplication: Remote.Class? = nil
local replicateClientCommand: Remote.Class? = nil
local TaskClient = {}
TaskClient.__index = TaskClient


-- LOCAL FUNCTIONS
local function setupReplicateListener()
	-- This sets-up a one-time listener for the whole server which isn't specific
	-- to this task
	if requestReplication then
		return
	end
	requestReplication = Remote.new("RequestReplication", "Function")
	if not requestReplication then
		return
	end
	local Task = require(script.Parent) :: any
	requestReplication:onServerInvoke(function(fromPlayer: Player, incomingUID, ...)
		-- Aim to keep requests to every 0.25 seconds or longer or you'll be rate limited
		-- The incoming arguments are also size-restricted (see below for amount)
		-- This is to minimise abuse
		local DELAY_BETWEEN_EACH_REQUEST = 0.1
		local LIMIT_PER_SECOND = 5
		local DATA_LIMIT = 250 -- bytes
		local matchingTask = Task.getTask(incomingUID)
		if not matchingTask then
			return true, "Invalid taskUID" -- true, because we want the warning to be silent as this can often occur when a task is randomly ended
		end
		local activeClientTasks = matchingTask.activeClientTasks
		local fromName = fromPlayer.Name
		local clientDetails = activeClientTasks[fromName]
		if typeof(clientDetails) ~= "table" then
			return false, "Invalid permission to replicate"
		end
		local commandName = matchingTask.commandName
		local replicator = matchingTask.client.replicator
		if typeof(replicator) ~= "function" then
			return false, `Command '{commandName}' has no defined replicator`
		end
		local function checkCooldown(cooldownKey: string, limit: number, cooldown: number)
			local initialRequests = activeClientTasks[cooldownKey]
			local requests = activeClientTasks[cooldownKey] or 0
			if requests >= limit then
				return false, `Only send requests every 0.25 seconds ({cooldownKey})`
			end
			requests += 1
			activeClientTasks[cooldownKey] = requests
			if not initialRequests then
				task.delay(cooldown, function()
					activeClientTasks[cooldownKey] = nil
				end)
			end
			return true, "Success"
		end
		local success1, warning1 = checkCooldown("Cooldown1", 4, DELAY_BETWEEN_EACH_REQUEST*2)
		if not success1 then
			return false, warning1
		end
		local success2, warning2 = checkCooldown("Cooldown2", LIMIT_PER_SECOND*3, 2)
		if not success2 then
			return false, warning2
		end
		local getDataSize = require(modules.VerifyUtil.getDataSize)
		local dataSize = getDataSize(table.pack(...))
		if dataSize > DATA_LIMIT then
			return false, `Exceeded replicate data limit of {DATA_LIMIT} bytes`
		end
		local function replicateTo(replicationTarget: Player, ...)
			if not replicateClientCommand then
				replicateClientCommand = Remote.new("ReplicateClientCommand", "Event")
			end
			if replicateClientCommand then
				replicateClientCommand:fireClient(replicationTarget, commandName, ...)
			end
		end
		replicator = replicator :: any
		replicator(replicateTo, ...)
		return true, "Success"
	end)
end


-- CONSTRUCTOR
function TaskClient.new(taskUID)

	-- Define properties
	local self = {
		taskUID = taskUID,
		replicator = nil,
	}
	setmetatable(self, TaskClient)

	return self
end


-- CLASS
type TargetType = getTargets.TargetType
export type Class = {
    run: typeof(TaskClient.run),
	replicator: ((replicate: (toPlayer: Player, ...any) -> (), ...any) -> ())?
}


-- METHODS
function TaskClient.run(self: Class, player: Player?, ...)
	if RunService:IsClient() then
		error("task.client should only be used on the server!")
	end
	local Task = require(script.Parent) :: any
	local anySelf = self :: any
	local task = Task.getTask(anySelf.taskUID)
	if not player or not task then
		return
	end
	if not runClientCommand then
		runClientCommand = Remote.new("RunClientCommand", "Event")
	end
	local clientArgs = table.pack(...)
	local properties = {
		callerUserId = task.callerUserId,
		targetUserId = task.targetUserId,
		commandName = task.commandName,
		UID = task.UID,
		clientArgs = clientArgs,
	}
	if runClientCommand then
		task.activeClientTasks[player.Name] = {}
		runClientCommand:fireClient(player, properties)
	end
	setupReplicateListener() -- Setup listener in case the client makes a replication request
end


return TaskClient