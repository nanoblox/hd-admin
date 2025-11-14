local hd = script:FindFirstAncestor("HD Admin")
local modules = hd.Core.MainModule.Value.Modules
local InputObjects = require(modules.Parser.InputObjects)

export type ArgumentDetail = {
	inputObject: InputObjects.InputConfig?,
	mustCreateAliasOf: string?,
	aliasOf: string?,
	description: string?,
	playerArg: boolean?,
	executeForEachPlayer: boolean?,
	parse: any?, --((...any) -> (...any))?,
	name: string?, -- Used for Arg.get(name)
	displayName: string?, -- The actual name shown within the UI, defaults to name
	defaultValue: any?,
	minValue: number?,
	maxValue: number?,
	stepAmount: number?,
	maxCharacters: number?,
}

return {}