--!strict
--[[
This abstracts all messaging-related popups for both server and client"
	> on SERVER: Prompt.info(player, text, options?)
	> on CLIENT: Prompt.info(text, options?)
--]]


-- LOCAL
local Prompt = {}
local RunService = game:GetService("RunService")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local promptRemote: Remote.Class? = nil


-- LOCAL FUNCTIONS
local function handleClient(promptType: PromptType, clientCallback: (text: string, options: PromptOptions?) -> (), playerOrText: unknown, textOrOptions: unknown, potentialOptions: unknown?)
	if RunService:IsClient() then
		local text = playerOrText :: any
		local options = textOrOptions :: any
		if typeof(text) ~= "string" then
			error("HD Admin: First argument must be a string (on the client)")
		end
		if options and typeof(options) ~= "table" then
			error("HD Admin: Second argument must be a PromptOptions table or empty (on the client)")
		end
		clientCallback(text, options)
		return
	end
	local player = playerOrText
	if player == nil then
		return
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
	local Remote = require(modules.Objects.Remote)
	if not promptRemote then
		promptRemote = Remote.new("Prompt", "Event")
	end
	if promptRemote then
		promptRemote:fireClient(player, promptType, text, options)
	end
	return
end


-- FUNCTIONS
function Prompt.info(...: Player? | string | PromptOptions?)
	handleClient("info", function(text, options)
		warn(`ℹ️ HD Admin Info: {text}`) -- Do client stuff
	end, ...)
end

function Prompt.success(...: Player? | string | PromptOptions?)
	handleClient("success", function(text, options)
		warn(`✅ HD Admin Success: {text}`) -- Do client stuff
	end, ...)
end

function Prompt.warn(...: Player? | string | PromptOptions?)
	handleClient("warn", function(text, options)
		warn(`⚠️ HD Admin Warn: {text}`) -- Do client stuff
	end, ...)
end

function Prompt.error(...: Player? | string | PromptOptions?)
	handleClient("error", function(text, options)
		warn(`⛔ HD Admin Error: {text}`) -- Do client stuff
	end, ...)
end

function Prompt.message(...: Player? | string | PromptOptions?)
	handleClient("message", function(text, options)
		warn(`💬 HD Admin Message: {text}`) -- Do client stuff
	end, ...)
end

function Prompt.hint(...: Player? | string | PromptOptions?)
	handleClient("hint", function(text, options)
		warn(`💡 HD Admin Hint: {text}`) -- Do client stuff
	end, ...)
end

function Prompt.action(...: Player? | string | PromptOptions?)
	handleClient("action", function(text, options)
		warn(`⚽ HD Admin Action: {text}`) -- Do client stuff
	end, ...)
end


-- TYPES
export type PromptType = keyof<typeof(Prompt)>
export type PromptOptions = {
	duration: number?,
}


return Prompt