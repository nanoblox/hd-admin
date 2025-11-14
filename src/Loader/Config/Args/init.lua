-- This enables you to create custom arguments for the commands you create.
-- Just make sure that the name (i.e. key) you provide is not the same
-- as any of the built-in arguments found inside HD Admin's Core Args module
-- Any args you create here will be accessible within command.args autocompletes


--!strict
-- LOCAL
local hd = script:FindFirstAncestor("HD Admin")
local modules = hd.Core.MainModule.Value.Modules
local ArgTypes = require(modules.Parser.Args.ArgTypes)
local function register(item: ArgumentDetail): ArgumentDetail
	return item :: ArgumentDetail
end


-- TYPES
type ArgumentDetail = ArgTypes.ArgumentDetail


-- ARGUMENTS
return function(Args)
	return {

		["TestNumber1"] = Args.createAliasOf("Number", register({
			minValue = -100,
			maxValue = 100,
		})),

		["TestNumber2"] = Args.createAliasOf("Number", register({
			minValue = 0,
			maxValue = 10000,
		})),

		["Number"] = Args.createAliasOf("Number", register({
			minValue = 0,
			maxValue = 10000,
		})),

	}
end