local hd = script:FindFirstAncestor("HD Admin")
local modules = hd.Core.MainModule.Value.Modules
local InputObjects = require(modules.Parser.InputObjects)

export type ArgumentDetail = {
	inputObject: InputObjects.InputConfig?,
	mustCreateAliasOf: string?,
	aliasOf: string?,
	description: string?,
	playerArg: boolean?,
	runForEachPlayer: boolean?,
	parse: any?, --((...any) -> (...any))?,
	key: string?, -- Used for Arg.get(name)
	displayName: string?, -- The actual name shown within the UI, defaults to name
	pickerText: string?, -- Text shown on label next to object
	defaultValue: any?,
	minValue: number?,
	maxValue: number?,
	maxItems: number?,
	stepAmount: number?,
	divAmount: number?,
	maxCharacters: number?,
	hasUpdatedParse: boolean?,
}

return {}