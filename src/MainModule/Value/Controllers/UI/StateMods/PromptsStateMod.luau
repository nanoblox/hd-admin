local HttpService = game:GetService("HttpService")

local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local States = require(UI.States)
local Fusion = require(Packages.Fusion)
local Sift = require(Packages.Sift)

export type Properties = {
	Title: { string }?,
	Body: { string }?,
	Callback: () -> ()?,
	Lifetime: number?,
}
export type Prompt = Properties & {
	Id: string,
}

local PromptsStateMod = {}

function PromptsStateMod:Push(Properties: Properties)
	assert(Properties ~= nil, "Properties is nil")

	local Prompt = Sift.Dictionary.merge({
		Id = HttpService:GenerateGUID(false),
		BirthTime = DateTime.now().UnixTimestampMillis,
		Lifetime = 5,
	}, Properties)

	Prompt.Callback = function()
		PromptsStateMod:Pull(Prompt.Id)

		if Properties.Callback ~= nil then
			Properties.Callback()
		end
	end

	local PromptsStateModValue: { Prompt } = Fusion.peek(States.Prompts.Prompts)

	table.insert(PromptsStateModValue, Prompt)

	States.Prompts.Prompts:set(PromptsStateModValue)

	if Prompt.Lifetime >= 1 then
		task.delay(Prompt.Lifetime, function()
			self:Pull(Prompt.Id)
		end)
	end
end

function PromptsStateMod:Pull(Id: string)
	local PromptsStateModValue: { Prompt } = Fusion.peek(States.Prompts.Prompts)
	local Index, _ = self:Get(Id)

	if Index then
		table.remove(PromptsStateModValue, Index)

		States.Prompts.Prompts:set(PromptsStateModValue)
	end
end

function PromptsStateMod:Get(Id: string): (number?, Prompt? | nil)
	local PromptsStateModValue: { Prompt } = Fusion.peek(States.Prompts.Prompts)

	for Index, Prompt in ipairs(PromptsStateModValue) do
		if Prompt.Id == Id then
			return Index, Prompt
		end
	end

	return nil
end

task.spawn(function()
	for Count = 1, 5 do
		task.wait(0.5)

		PromptsStateMod:Push {
			Title = { "Welcome to HD Admin UI!" },
			Body = { "This is a sample prompt to demonstrate the system." },
			Lifetime = -1,
			Callback = function()
				print("Prompt closed!")
			end,
		}
	end
end)

return PromptsStateMod
