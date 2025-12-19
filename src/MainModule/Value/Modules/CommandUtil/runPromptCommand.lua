--!strict
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
return function(promptType: Prompt.PromptType, task: Task.Class, targets: {Player}, text: string, options: Prompt.PromptOptions?)
	local getMessageTime = require(modules.CommandUtil.getMessageTime)
	local messageTime = getMessageTime(text)
	for _, target in targets do
		local prompt = (Prompt :: any)[promptType]
		task.janitor:add(prompt(target, text, options))
	end
	task.wait(messageTime)
end