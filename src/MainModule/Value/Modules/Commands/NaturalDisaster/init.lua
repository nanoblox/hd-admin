--!strict
-- LOCAL
local Commands = require(script.Parent)
--local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- COMMANDS
local commands: {Commands.Command} = {
	
    --------------------
    {
		name = "hi",
		args = {"Player"},
	},


    --------------------
	{
		name = "test",
		args = {"Player"},
	},


    --------------------
	{
		name = "test",
		args = {"Player"},
	},

    --------------------
}


-- RETURN
return commands