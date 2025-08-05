--!strict
-- LOCAL
local Commands = require(script.Parent)
--local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- COMMANDS
local commands: {Commands.Command} = {
	
    --------------------
    {
		name = "ddd",
		aliases = {"ddd2"},
		args = {"ddd"},
	},


    --------------------
	{
		name = "eee",
		aliases = {"eee2"},
		args = {"Player"},
	},


    --------------------
	{
		name = "fff",
		aliases = {"fff2"},
		args = {"Player"},
	},

    --------------------
}


-- RETURN
return commands