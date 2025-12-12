-- LOCAL
--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local RunService = game:GetService("RunService")
local requestReplication: Remote.Class? = nil
local TaskServer = {}
TaskServer.__index = TaskServer


-- CONSTRUCTOR
function TaskServer.new(taskUID)

	-- Define properties
	local self = {
		taskUID = taskUID
	}
	setmetatable(self, TaskServer)

	return self
end


-- CLASS
export type Class = {
    replicate: typeof(TaskServer.replicate),
}


-- METHODS
function TaskServer.replicate(self: Class, ...)
	if RunService:IsServer() then
		error("task.server should only be used on the client!")
	end
	if not requestReplication then
		requestReplication = Remote.get("RequestReplication")
	end
	if not requestReplication then
		return
	end
	local Task = require(script.Parent) :: any
	local anySelf = self :: any
	local task = Task.getTask(anySelf.taskUID)
	if not task then
		return
	end
	local taskUID = task.UID
	local thisRemote = requestReplication
	local packedArgs = {...}
	task.defer(function()
		if not task.isActive then
			return
		end
		local success, warning = thisRemote:invokeServerAsync(taskUID, unpack(packedArgs))
		if not task.isActive then
			return
		end
		if not success then
			warn("!!! notice: Future HD Admin warning: ".. tostring(warning))
			return
		end
	end)
end


return TaskServer