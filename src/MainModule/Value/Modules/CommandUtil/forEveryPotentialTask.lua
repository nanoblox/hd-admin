-- Its important to split commands into specific users for most cases so that the command can
-- be easily reapplied if the player rejoins (for ones where the perm modifier is present)
-- The one exception for this is when a global modifier is present. In this scenerio, don't save
-- specific targetPlayers, simply use the qualifiers instead to select a general audience relevant for
-- the particular server at time of exection.
-- e.g. ``;permLoopKillAll`` will save each specific targetPlayer within that server and permanetly loop kill them
-- while ``;globalLoopKillAll`` will permanently save the loop kill action and execute this within all
-- servers repeatidly

local mainValue = script:FindFirstAncestor("MainModule").Value
local modules = mainValue.Modules
local services = mainValue.Services
local parser = modules.Parser
local ParserTypes = require(parser.ParserTypes)
local Task = require(modules.Objects.Task)

type Statement = ParserTypes.ParsedStatement
type Command = Task.Command
type ArgGroup = {[string]: {string}}
type Task = Task.Class
type Properties = Task.Properties

return function(callerUserId: number, statement: Statement, callback: (command: Command, arguments: ArgGroup, optionalTargetUserId: number?) -> (boolean?))
	local Commands = require(services.Commands :: any)
	local Args = require(parser.Args)
	local tasks: {any} = {}
	local isPermModifier = statement.modifiers.perm
	local isGlobalModifier = statement.modifiers.wasGlobal
	for commandName, arguments in statement.commands do
		
		local command = Commands.getCommand(commandName) :: Command?
		if not command or typeof(command.args) ~= "table" then
			continue
		end
		
		-- Its important to split commands into specific users for most cases so that the command can
		-- be easily reapplied if the player rejoins (for ones where the perm modifier is present)
		-- The one exception for this is when a global modifier is present. In this scenerio, don't save
		-- specific targetPlayers, simply use the qualifiers instead to select a general audience relevant for
		-- the particular server at time of exection.
		-- e.g. ``;permLoopKillAll`` will save each specific targetPlayer within that server and permanetly loop kill them
		-- while ``;globalLoopKillAll`` will permanently save the loop kill action and execute this within all
		-- servers repeatidly
		local addToPerm = false
		local splitIntoUsers = false
		local firstArgNameOrDetail = command.args[1]
		local firstArg = Args.get(firstArgNameOrDetail)
		local runForEachPlayer = if firstArg then firstArg.runForEachPlayer else false
		if isPermModifier then
			if isGlobalModifier then
				addToPerm = true
			elseif runForEachPlayer then
				addToPerm = true
				splitIntoUsers = true
			end
		else
			splitIntoUsers = runForEachPlayer
		end

		-- Define the properties that we'll create the task from arguments
		local args = (arguments or {}) :: ArgGroup
		local qualifiers = (statement.qualifiers or {}) :: ArgGroup
		local modifiers = (statement.modifiers or {}) :: ArgGroup

		-- Create task wrapper
		local function newPotentialTask(optionalTargetUserId: number?)
			return callback(command, args, optionalTargetUserId)
		end

		-- Tasks are split into separate players (such as those with the 'Player' arg),
		-- while some do not (such as those with the 'Players' arg, or without any type
		-- of player arg at all)
		if not splitIntoUsers then
			newPotentialTask()
		else
			local targetPlayers = if firstArg then firstArg:parse(statement.qualifiers, callerUserId) else {}
			for _, plr in targetPlayers do
				local keepRunning = newPotentialTask(plr.UserId)
				if keepRunning == false then
					break
				end
			end
		end
	end
end