--[[

	Description of Task class

	To do:
		- Have a :buff method, which simply accepts a player and function, then calls that
		function every time a 'refesh' is performedn, and if is the 'top' (most recent) buff.
		A 'refresh' occurs every time :buff is called (for any task, this or others) for that
		particular player, and right after every task with a janitor is cleaned up. Then
		test this with commands like speed and ice.

]]


-- LOCAL
--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Janitor = require(modules.Objects.Janitor)
local Players = game:GetService("Players")
local Args = require(modules.Parser.Args)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Task = {_getters = {}, _methods = {}}
Task.__index = Task


-- FUNCTIONS
function Task._getters.getTask()
	
end

function Task._getters.getTasksWithCommandNameAndOptionalPlayerUserId(commandName: string, optionalPlayerUserId: number?): {Class}
	return {}
end


-- CONSTRUCTOR
function Task.new(properties: Properties)
	
	-- Define properties
	local Commands = require(modules.Commands) :: any
	local janitor = Janitor.new()
	local commandName = properties.commandName
	local command = if isServer then Commands.getCommand(commandName) :: Command else nil --or main.modules.ClientCommands.get(self.commandName)
	local callerUserId = properties.callerUserId
	local playerUserId = properties.playerUserId
	local cooldown = if command then command.cooldown else nil
	local self = {
		janitor = janitor,
		isActive = true :: any,
		caller = if callerUserId then Players:GetPlayerByUserId(callerUserId) else nil,
		_properties = {
			callerUserId = callerUserId,
			playerUserId = playerUserId,
			commandName = commandName,
			args = properties.args,
			modifiers = properties.modifiers,
			qualifiers = properties.qualifiers,
			isRestricted = properties.isRestricted,
			command = command,
			cooldown = if typeof(cooldown) == "number" then cooldown else 0,
			cooldownEndTime = 0,
			player = if playerUserId then Players:GetPlayerByUserId(playerUserId) else nil,
		},
	}
	setmetatable(self, Task)

	self._methods.run(self)

	return self
end


-- CLASS
export type Class = typeof(Task.new(...))
export type TriStateSetting = "Default" | "True" | "False"
export type Properties = {
	UID: string?,
	callerUserId: number,
	playerUserId: number?,
	commandName: string,
	commandNameLower: string?,
	args: {[string]: {string}},
	modifiers: {[string]: {string}}?,
	qualifiers: {[string]: {string}}?,
	isRestricted: boolean?,
}
export type Command = {
	--[string]: any,
	name: string,
	aliases: {string},
	args: {Args.Argument},
	prefixes: {string}?,
	autoPreview: boolean?,
	revokeRepeats: boolean?,
	preventRepeats: TriStateSetting?,
	cooldown: number?,
	run: ((Class, {any}) -> ())?,
}
export type ClientCommand = {
	--[string]: any,
	name: string,
	args: {Args.Argument},
	--run: (() -> ()),
}


-- PRIVATE METHODS
function Task._methods.run(self: Class)
	-- This is what parses the args and runs the actual command function
	
	-- Only run if command is present
	local command = self._properties.command
	local run = command and command.run
	if not run then
		return
	end

	--
	local Promise = main.modules.Promise
	if self.executing or self.isDead then
		return Promise.defer(function(_, reject)
			reject("Execution already running!")
		end)
	end
	self.executing = true

	local command = self.command
	local firstCommandArg
	local firstArgItem
	if self.args then
		firstCommandArg = command.args[1]
		firstArgItem = main.modules.Parser.Args.get(firstCommandArg)
	end

	local invokedCommand = false
	local function invokeCommand(parseArgs, ...)
		local additional = table.pack(...)
		invokedCommand = true
		
		-- Convert arg strings into arg values
		-- Only execute the command once all args have been converted
		-- Some arg parsers, such as text, may be aschronous due to filter requests
		local promises = {}
		local filteredAllArguments = false
		if main.isServer and parseArgs and self.args then
			local currentArgs = additional[1]
			local parsedArgs = (type(currentArgs) == "table" and currentArgs)
			if not parsedArgs then
				parsedArgs = {}
				additional[1] = parsedArgs
			end
			local firstAlreadyParsedArg = parsedArgs[1]
			local i = #parsedArgs + 1
			for _, _ in pairs(command.args) do
				local iNow = i
				local argName = command.args[iNow]
				local argItem = main.modules.Parser.Args.get(argName)
				if not argItem then
					break
				end
				local argStringIndex = (firstAlreadyParsedArg and iNow - 1) or iNow
				local argString = self.args[argStringIndex] or ""
				if argItem.playerArg then
					argString = {
						[argString] = {}
					}
				end
				local promise = main.modules.Promise.defer(function(resolve)
					local returnValue = argItem:parse(argString, self.callerUserId, self.playerUserId)
					resolve(returnValue)
				end)
				table.insert(promises, promise
					:andThen(function(returnValue)
						return returnValue
					end)
					:catch(warn)
					:andThen(function(returnValue)
						local argNameLower = tostring(argName):lower()
						self.originalArgReturnValues[argNameLower] = returnValue
						self.originalArgReturnValuesFromIndex[iNow] = returnValue
						if returnValue == nil then
							local defaultValue = argItem.defaultValue
							if typeof(defaultValue) == "table" then
								defaultValue = main.modules.TableUtil.copy(argItem.defaultValue)
							end
							returnValue = defaultValue
						end
						parsedArgs[iNow] = returnValue
					end)
				)
				i += 1
			end
		end
		main.modules.Promise.all(promises)
			:finally(function()
				filteredAllArguments = true
			end)
		
		local finishedInvokingCommand = false
		self:track(main.modules.Thread.delayUntil(function() return finishedInvokingCommand == true end))
		self:track(main.modules.Thread.delayUntil(function() return filteredAllArguments == true end, function()
			xpcall(command.invoke, function(errorMessage)
				-- This enables the job to be cleaned up even if the command throws an error
				self:kill()
				warn(debug.traceback(tostring(errorMessage), 2))
			end, self, unpack(additional))
			finishedInvokingCommand = true
		end))
	end--]]

	-- Finally, run the command with the task and parsed args as arguments
	local function errorHandler(errorMessage)
		-- This enables the job to be cleaned up even if the command throws an error
		self:destroy()
		warn(debug.traceback(tostring(errorMessage), 2))
	end
	--xpcall(run, errorHandler, self, unpack(additional))
	xpcall(run, errorHandler, self, self._properties.args)
	
	
end


-- PUBLIC METHODS
function Task.defer(self: Class, hi: (any))
	
end

function Task.buff(self: Class)
end

function Task.destroy(self: Class)
	if self.isActive == false then
		return
	end
	self.isActive = false
	self.janitor:destroy()
end


return Task