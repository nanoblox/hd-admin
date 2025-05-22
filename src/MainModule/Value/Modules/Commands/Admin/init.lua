--!strict
-- LOCAL
local Commands = require(script.Parent)
local modules = script:FindFirstAncestor("MainModule").Value.Modules


-- LOCAL FUNCTIONS
type Command = Commands.Command
local function register(item: Command): Command
	return item :: Command -- We do this to support type checking within the table
end


-- COMMANDS
local commands: {Command} = {
	
    --------------------
    register({
		name = "dance",
		aliases = {"dce"},
		args = {"Player"},
		prefixes = {"/", "@"},
	}),


    --------------------
	{
		name = "dance2",
		aliases = {"bbb2"},
		args = {"Player"},
		prefixes = {"#", "@"},
	},


    --------------------
	register({
		name = "fly",
		aliases = {"ccc2"},
		args = {"Player"},
		run = function(task, args)
			-- This is a test command
			print("Fly command executed with args: ", task, args)
		end,
	}),

    --------------------
}


-- RETURN
return commands