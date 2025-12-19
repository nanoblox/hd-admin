--!strict
local TestService = {}
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules

-- Test User
local User = require(modules.Objects.User)
task.defer(function()
	Players.PlayerAdded:Connect(function(player: Player)
		local success, user = User.getUserAsync(player)
		if success then
			
			-- Set prefix
			--user.perm:set("YouSettings", "Prefix", "!")
			
			-- Set Volume/Pitch
			user.perm:set("YouSettings", "Sound", "Pitch", "Command", 2)
			task.delay(10, function()
				user.perm:set("YouSettings", "Sound", "Pitch", "Command", 1)
			end)

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
local areValuesEqual = require(modules.DataUtil.areValuesEqual)
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

	for _, testCase in pairs(testCases) do
		local v1, v2, expected = unpack(testCase :: any)
		local result = areValuesEqual(v1, v2)
		assert(result == expected, `Expected {v1} and {v2} to be {expected}, but got {result}`)
	end
end
--testAreValuesEqual()

print("GET OWNER INFO (1)")
local ownerInfo = require(modules.References.ownerInfo)
print("ownerInfo =", ownerInfo)
print("GET OWNER INFO (2)")

return TestService