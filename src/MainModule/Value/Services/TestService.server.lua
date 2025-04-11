--!strict
local Players = game:GetService("Players")

-- Cancel run if another application has initialized
local modules = script:FindFirstAncestor("MainModule").Value.Modules
if require(modules.Framework).startAsync() == false then
    return
end

-- Test Cash / Saving
task.defer(function()
	local User = require(modules.Objects.User)
	local player = Players:WaitForChild("ForeverHD") :: Player
	local success, user = User.getUserAsync(player)
	if success then
		while user.isActive do
			user.perm:update("Cash", function(value: number)
				return value + 1
			end)
			task.wait(5)
		end
	end
end)

-- Test Parser
local Qualifiers = require(modules.Parser.Qualifiers)
print("NonAdmins =", Qualifiers.get("NonAdmins"))

local Modifiers = require(modules.Parser.Modifiers)
print("Un =", Modifiers.get("Un"))

local Args = require(modules.Parser.Args)
print("UnfilteredString =", Args.get("UnfilteredText"))