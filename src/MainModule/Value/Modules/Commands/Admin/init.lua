--!strict
-- LOCAL
local Commands = require(script.Parent)
--local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- COMMANDS
local commands: {Commands.Command} = {
	
    --------------------
    {
		name = "dance",
		aliases = {"dce"},
		args = {"Player"},
		prefixes = {"/", "@"},
	},


    --------------------
	{
		name = "dance2",
		aliases = {"bbb2"},
		args = {"Player"},
		prefixes = {"#", "@"},
	},


    --------------------
	{
		name = "fly",
		aliases = {"ccc2"},
		args = {"Player"},
	},

    --------------------
}


-- RETURN
return commands