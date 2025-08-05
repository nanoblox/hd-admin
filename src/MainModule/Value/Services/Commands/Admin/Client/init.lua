--!strict
-- LOCAL
local Commands = require(script.Parent.Parent)
--local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- COMMANDS
local client: {Commands.ClientCommand} = {
	
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
return client