local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local States = require(UI.States)
local Fusion = require(Packages.Fusion)

export type Task = {
	TaskId: string, -- GUID
	CommandId: string,
}

local TasksStateMod = {}

function TasksStateMod.Remove(Task: Task)
	TasksStateMod._Update(function(Tasks)
		local IndexToRemove = nil

		for OtherIndex, OtherTask in Tasks do
			if OtherTask.TaskId == Task.TaskId then
				IndexToRemove = OtherIndex
			end
		end

		if IndexToRemove ~= nil then
			table.remove(Tasks, IndexToRemove)

			return Tasks
		end
	end)
end

function TasksStateMod.Add(Task: Task)
	TasksStateMod._Update(function(Tasks)
		table.insert(Tasks, Task)

		return Tasks
	end)
end

function TasksStateMod._Update(Updater: ({ Task }) -> { Task })
	local TasksValue = Fusion.peek(States.Commands.Tasks)
	local NewValue = Updater(TasksValue)

	if NewValue ~= nil then
		States.Commands.Tasks:set(NewValue)
	end
end

return TasksStateMod
