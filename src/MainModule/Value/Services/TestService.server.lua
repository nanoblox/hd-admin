--!strict
local Players = game:GetService("Players")

-- Cancel run if another application has initialized
local modules = script:FindFirstAncestor("MainModule").Value.Modules
if require(modules.Framework).startAsync() == false then
    return
end

-- Test User
local User = require(modules.Objects.User)
task.defer(function()
	Players.PlayerAdded:Connect(function(player: Player)
		local success, user = User.getUserAsync(player)
		if success then
			
			-- Set prefix
			print("user.perm (1) =", user.perm, user.perm:get("PlayerSettings", "Prefix"))
			user.perm:set("PlayerSettings", "Prefix", "!")
			print("user.perm (2) =", user.perm, user.perm:get("PlayerSettings", "Prefix"))

			-- Cash Giver
			while user.isActive do
				user.perm:update("Cash", function(value: number)
					return value + 1
				end)
				task.wait(5)
			end

		end
	end)
end)

local everyone = User.everyone
task.defer(function()
	while true do
		task.wait(5)
		everyone:update("Test", function(value: number)
			local realValue = value or 0
			return realValue + 5
		end)
	end
end)


-- Test Parser
--[[
local Qualifiers = require(modules.Parser.Qualifiers)
print("NonStaff =", Qualifiers.get("NonStaff"))
print("nonstaff =", Qualifiers.get("nonstaff"))

local Modifiers = require(modules.Parser.Modifiers)
print("unn =", Modifiers.get("unn"))
print("tesToNe =", Modifiers.get("tesToNe"))

local Args = require(modules.Parser.Args)
print("oPtIonalplaYers =", Args.get("oPtIonalplaYers"))
--]]


-- Are Values Equal
local areValuesEqual = require(modules.Utility.DataUtil.areValuesEqual)
local function testAreValuesEqual()
	local testCases = {
		{1, 1, true},
		{1, 2, false},
		{"hello", "hello", true},
		{"hello", "world", false},
		{true, true, true},
		{true, false, false},
		{false, false, true},
		{nil, nil, true},
		{nil, 0, false},
		{Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), true},
		{Color3.fromRGB(255, 0, 0), Color3.fromRGB(94, 255, 0), false},
	}

	for _, testCase in ipairs(testCases) do
		local v1, v2, expected = unpack(testCase)
		local result = areValuesEqual(v1, v2)
		assert(result == expected, `Expected {v1} and {v2} to be {expected}, but got {result}`)
	end
end
--testAreValuesEqual()