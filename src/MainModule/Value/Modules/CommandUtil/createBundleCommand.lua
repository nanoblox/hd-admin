--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local runBundleId = require(modules.OutfitUtil.runBundleId)
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
return function (commandName: string, bundleId: number, properties: {[string]: any}?)
	local aliases = if properties then properties.Aliases else nil
	local command: Task.Command = {
		name = commandName,
		aliases = aliases,
		groups = {"Bundle"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			return runBundleId(task, bundleId, properties)
		end
	}
	return command
end