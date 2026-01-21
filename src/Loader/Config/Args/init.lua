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

		["Scale"] = Args.createAliasOf("Number", register({
			-- This can be exceeded if a user has a role with 'bypassLimits' enabled
			minValue = 0.01,
			maxValue = 4,
		})),

		["Distance"] = Args.createAliasOf("Number", register({
			-- Nothing to change, just an alias
		})),

		["CountdownTime"] = Args.createAliasOf("Number", register({
			-- This can be exceeded if a user has a role with 'bypassLimits' enabled
			minValue = 1,
			stepAmount = 1,
			maxValue = 60,
		})),
		
		["FlightSpeed"] = Args.createAliasOf("Number", register({
			-- This can be exceeded if a user has a role with 'bypassLimits' enabled
			-- This is used for Emotes, etc
			minValue = 1,
			maxValue = 10000,
			stepAmount = 1,
			defaultValue = 50,
		})),

		["AnimationSpeed"] = Args.createAliasOf("Number", register({
			-- This can be exceeded if a user has a role with 'bypassLimits' enabled
			-- This is used for Emotes, etc
			minValue = 0.5,
			maxValue = 2,
			stepAmount = 0.1,
			defaultValue = 1,
		})),

		["ServersOptions"] = Args.createAliasOf("Options", register({
			inputObject = {
				inputType = "Options",
				optionsArray = {"Current", "All"}
			},
		})),

		["BanLengthOptions"] = Args.createAliasOf("Options", register({
			inputObject = {
				inputType = "Options",
				optionsArray = {"Infinite", "Time"}
			},
		})),

		--[[["ClearEverythingBool"] = Args.createAliasOf("Bool", register({
			pickerText = "Clear Everything? (i.e. tasks also with targets)",
			defaultValue = false,
		})),--]]

	}
end