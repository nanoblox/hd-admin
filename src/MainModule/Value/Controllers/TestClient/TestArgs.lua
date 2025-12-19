local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local foreverhd = Players:WaitForChild("ForeverHD", 999999)
local leaderstats = foreverhd:WaitForChild("leaderstats")
local cashStat = leaderstats:WaitForChild("Cash")
local Teams = game:GetService("Teams")
local korbloxTeam = Teams:FindFirstChild("Korblox")
local testTool = ReplicatedStorage:FindFirstChild("TestToolHi")

local args = {
	{["Player"] = {foreverhd, "others", "role(admin)"}},
	{["AnyUser"] = 82347291},
	{["Roles"] = {"admin", "mod"}},
	{["Text"] = "Hello world || German"},
	{["SingleText"] = "HelloworldSpanish"},
	{["UnfilteredText"] = "Hello world French"},
	{["Code"] = "Hello world 3"},
	{["Number"] = 123322359},
	{["Integer"] = "inf"},
	{["Speed"] = 123},
	{["Duration"] = 31540001},
	{["Color"] = Color3.fromRGB(125, 0, 0)},
	{["Colour"] = Color3.fromRGB(11, 110, 121)},
	{["OptionalColor"] = Color3.fromRGB(224, 15, 78)},
	{["Bool"] = true},
	{["Options"] = "Yes"},
	{["Leaderstat"] = cashStat},
	{["Team"] = korbloxTeam},
	{["Material"] = Enum.Material.Sandstone},
	{["Tool"] = testTool},
	{["Fields"] = {
		"Grape Fruit",
		"Pineapple Cake",
		"Strawberry"
	}},
}

local testArgs = {}
local testValues = {}


for _, group in args do
	local key, value
	for keyHere, valueHere in group do
		key, value = keyHere, valueHere
		break
	end
	table.insert(testArgs, key)
	table.insert(testValues, value)
end

return {testArgs, testValues}