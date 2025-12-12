--!strict
-- This wraps internal functions and behaviours to make HD Admin safe and easy to modify
-- (because internal service and controller functions are subject to change, whereas
-- existing API functions will always remain constant)
-- If you'd like to see a specific function added, please open an issue on our GitHub


-- LOCAL
local API = {}
local hasLoaded = script:WaitForChild("HasLoaded", 999)
local RunService = game:GetService("RunService")
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Prompt = require(modules.Prompt)
local Framework = require(modules.Framework)


-- LOCAL FUNCTIONS
local function isServer()
	if not RunService:IsServer() then
		error("API function only accessable on server")
	end
	Framework.waitUntilLoaded()
end

local function isShared()
	Framework.waitUntilLoaded()
end

local function isClient()
	if not RunService:IsClient() then
		error("API function only accessable on client")
	end
	Framework.waitUntilLoaded()
end


-- SERVER FUNCTIONS
function API.requestCommand(message: string, optionalFromPlayer: Player?)
	-- With v2, you can now run commands without an associated player (caller)
	-- Instead, if no 'fromPlayer' is given, a default 'Server User' will take
	-- it's place, enabling commmands to run as normal from anywhere
	isServer()
	local Commands = require(modules.Parent.Services.Commands)
	local User = require(modules.Objects.User)
	local user: User.Class?
	if typeof(optionalFromPlayer) == "Instance" and optionalFromPlayer:IsA("Player") then
		local success, playerUser = User.getUserAsync(optionalFromPlayer)
		if not success then
			return false, {{false, `{optionalFromPlayer}`}}, {}
		end
		user = playerUser
	else
		user = Commands.getServerUser()
	end
	user = user :: User.Class
	local approved, notices, tasks = Commands.request(user, message, "API")
	if optionalFromPlayer then
		Commands.processNotices(optionalFromPlayer, notices)
	end
	return approved, notices, tasks
end

function API.disableCommands(player: Player, boolean: boolean?)
	isServer()

end

function API.giveRoleAsync()
	isServer()

end

function API.takeRoleAsync()
	isServer()
	
end

function API.getRolesAsync()
	isServer()
	
end


-- SHARED FUNCTIONS
function API.prompt(promptType: Prompt.PromptType, ...: Player? | string | Prompt.PromptOptions?)
	-- > on SERVER: Prompt.info(promptType, player, text, options?)
	-- > on CLIENT: Prompt.info(promptType, text, options?)
	isShared()
	local func = (Prompt :: any)[promptType :: any] :: any
	return func(...)
end


-- CLIENT FUNCTIONS
function API.getAppIcon()
	isClient()
	return require(modules.References.appIcon)
end


return API
