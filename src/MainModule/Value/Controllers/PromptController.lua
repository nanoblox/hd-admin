--!strict
-- LOCAL
local PromptController = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local Prompt = require(modules.Prompt)


-- TYPES
type PromptType = Prompt.PromptType
type PromptOptions = Prompt.PromptOptions


-- SETUP
Remote.get("Prompt"):onClientEvent(function(promptType: PromptType, text: string, options: PromptOptions?)
	local func = (Prompt :: any)[promptType :: any] :: any
	func(text, options)
end)


return PromptController