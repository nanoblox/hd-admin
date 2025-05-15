--!strict
-- LOCAL
local Commands = require(script.Parent)
--local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- COMMANDS
local commands: {Commands.Command} = {
	
    --------------------
    {
		name = "ggg",
		aliases = {"ggg2"},
		args = {"Player"},
	},


    --------------------
	{
		name = "hhh",
		aliases = {"hhh2"},
		args = {"Player"},
	},


    --------------------
	{
		name = "iii",
		aliases = {"iii2"},
		args = {"Player"},
	},

    --------------------
}


-- RETURN
return commands