--!strict
--[[
This abstracts all networking for prompt-related popups on both server and client:
	> on SERVER: Prompt.info(player, text, options?)
	> on CLIENT: Prompt.info(text, options?)
--]]

-- To do:
-- 1. Complete Disconnect so that it ends the prompt for both server and client


-- LOCAL
local Prompt = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local promptRemote: Remote.Class? = nil
local createConnection = require(modules.AssetUtil.createConnection)


-- LOCAL FUNCTIONS
local function handleClient(promptType: PromptType, clientCallback: (text: string, options: PromptOptions?) -> (any), playerOrText: unknown, textOrOptions: unknown, potentialOptions: unknown?): Disconnect
	local getUserInfoAsync = require(modules.PlayerUtil.getUserInfoAsync)
	local function addInUserInfo(options: PromptOptions? | any?): PromptOptions? | any?
		if typeof(options) ~= "table" then
			return options
		end
		local fromUserId = options.fromUserId
		if not fromUserId or options.fromUserName then
			return options
		end
		local success, info = getUserInfoAsync(fromUserId)
		if not success or typeof(info) ~= "table" then
			return options
		end
		options.fromUserName = info.userName
		options.fromUserImage = info.userImage
		options.fromUserDisplayName = info.userDisplayName
		options.fromUserRole = info.userPrimaryRole
		return options
	end
	if RunService:IsClient() then
		local text = playerOrText :: any
		local options = textOrOptions :: any
		if typeof(text) ~= "string" then
			error("HD Admin: First argument must be a string (on the client)")
		end
		if options and typeof(options) ~= "table" then
			error("HD Admin: Second argument must be a PromptOptions table or empty (on the client)")
		end
		addInUserInfo(options)
		local noticeInstance = clientCallback(text, options)
		return createConnection(function()
			-- Destroy the client prompt object
			noticeInstance:Destroy()
		end)
	end
	local player = playerOrText
	if player == nil then
		-- Do nothing when disconnected as nothing was created in first place
		return createConnection(function() end)
	end
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		error("HD Admin: First argument must be a Player (on the server)")
	end
	local text = textOrOptions
	if typeof(text) ~= "string" then
		error("HD Admin: Second argument must be a string (on the server)")
	end
	local options = potentialOptions
	if options and typeof(options) ~= "table" then
		error("HD Admin: Third argument must be a PromptOptions table or empty (on the server)")
	end
	addInUserInfo(options)
	local Remote = require(modules.Objects.Remote)
	if not promptRemote then
		promptRemote = Remote.new("Prompt", "Event")
	end
	if promptRemote then
		promptRemote:fireClient(player, promptType, text, options)
	end
	return createConnection(function()
		-- Fire to client to destroy the prompt
	end)
end


-- FUNCTIONS
function Prompt.info(...: Player? | string | PromptOptions?): Disconnect
	-- Sidebar notice with standard notify sound
	return handleClient("info", function(text, options)

		------------ UI CODE ------------
		warn(`ℹ️ HD Admin Info: {text}`) -- Do client stuff
		return -- Make sure to return the notice instance or a table with .Destroy, as this can be cleaned up
		---------------------------------
		
	end, ...)
end

function Prompt.success(...: Player? | string | PromptOptions?): Disconnect
	-- Sidebar notice with success sound
	return handleClient("success", function(text, options)
		
		------------ UI CODE ------------
		warn(`✅ HD Admin Success: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.warn(...: Player? | string | PromptOptions?): Disconnect
	-- Sidebar notice with warn sound
	return handleClient("warn", function(text, options)

		------------ UI CODE ------------
		warn(`⚠️ HD Admin Warn: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------
		
	end, ...)
end

function Prompt.error(...: Player? | string | PromptOptions?): Disconnect
	-- Sidebar notice with error sound
	return handleClient("error", function(text, options)
		
		------------ UI CODE ------------
		warn(`⛔ HD Admin Error: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.message(...: Player? | string | PromptOptions?): Disconnect
	-- Full screen ;message
	return handleClient("message", function(text, options)
		
		------------ UI CODE ------------
		warn(`💬 HD Admin Message: {text}`) -- Do client stuff
		print("options =", options)
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.hint(...: Player? | string | PromptOptions?): Disconnect
	-- Top of screen ;hint
	return handleClient("hint", function(text, options)
		
		------------ UI CODE ------------
		warn(`💡 HD Admin Hint: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.privateMessage(...: Player? | string | PromptOptions?): Disconnect
	-- Sidebar notice with text 'Private Message from USER' and opens message on click
	return handleClient("privateMessage", function(text, options)
		
		------------ UI CODE ------------
		warn(`🗣️ HD Admin PrivateMessage: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.alert(...: Player? | string | PromptOptions?): Disconnect
	-- Sidebar notice with alert toggle that can turned off/on
	return handleClient("alert", function(text, options)
		
		------------ UI CODE ------------
		warn(`🚨 HD Admin Alert: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.vote(...: Player? | string | PromptOptions?): Disconnect
	-- The 'select options to vote' menu that appears
	return handleClient("vote", function(text, options)
		
		------------ UI CODE ------------
		local fields = if options and options.fields then options.fields else {}	
		warn(`🚨 HD Admin Vote: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end

function Prompt.action(...: Player? | string | PromptOptions?): Disconnect
	-- This is how a command action (such as fly, dance menu, etc) should be prompted
	return handleClient("action", function(text, options)
		
		------------ UI CODE ------------
		warn(`⚽ HD Admin Action: {text}`) -- Do client stuff
		return -- Notice object
		---------------------------------

	end, ...)
end


-- TYPES
type Disconnect = createConnection.Disconnect
export type PromptType = keyof<typeof(Prompt)>
export type PromptOptions = {
	title: string?,
	duration: number?,
	color: Color3?,
	fields: {string}?,
	fromUserId: number? | string?,
	fromUserName: string?, -- Filled in automatically if fromUserId is provided
	fromUserImage: string?, -- Filled in automatically if fromUserId is provided
	fromUserDisplayName: string?, -- Filled in automatically if fromUserId is provided
	fromUserRole: string?, -- Filled in automatically if fromUserId is provided
}


return Prompt