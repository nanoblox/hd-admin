--!strict
-- LOCAL
local Commands = require(script.Parent)
--local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- COMMANDS
local commands: {Commands.Command} = {
	
    --------------------
    {
		name = "jjj",
		aliases = {"jjj2"},
		args = {"Player"},
	},


    --------------------
	{
		name = "kkk",
		aliases = {"kkk2"},
		args = {"Player"},
	},


    --------------------
	{
		name = "lll",
		aliases = {"lll2"},
		args = {"Player"},
	},

    --------------------
}


-- RETURN
return commands