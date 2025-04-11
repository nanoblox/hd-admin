--!strict


-- LOCAL
local Commands = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local parser = modules.Parser
local Args = require(parser.Args)


-- TYPES
export type Task = {
	defer: (any, any) -> (),
	hiiiiii: (any, any) -> (),
}

export type Command = {
	--[string]: any,
	name: string,
	args: {Args.Argument},
}

export type ClientCommand = {
	--[string]: any,
	name: string,
	args: {Args.Argument},
	--run: (() -> ()),
}



return Commands