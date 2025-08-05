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
			--user.perm:set("PlayerSettings", "Prefix", "!")
			
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

	for _, testCase in ipairs(testCases) do
		local v1, v2, expected = unpack(testCase)
		local result = areValuesEqual(v1, v2)
		assert(result == expected, `Expected {v1} and {v2} to be {expected}, but got {result}`)
	end
end
--testAreValuesEqual()



-- Test config
-- Test something
--[[
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Config = require(modules.Config)
local playerIdentifier = Config.getSetting("PlayerIdentifier")
local collective = Config.getSetting("Collective")
local names = {"ForeverHD", "ImAvafe", "ObliviousHD"}
local selectionText = table.concat(
    table.create(#names, ""),
    ""
)
for i, name in ipairs(names) do
    selectionText ..= playerIdentifier .. name
    if i < #names then
        selectionText ..= collective .. " "
    end
end

print("selectionText =", selectionText)
--]]


return TestService