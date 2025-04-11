local Players = game:GetService("Players")
local main = script:FindFirstAncestor("MainModule")
local State = require(main.Value.Modules.Objects.State)
local localPlayer = Players.LocalPlayer
local userId = localPlayer.UserId

local perm = State.new()
perm:bind(`UserPerm_{userId}`)

local temp = State.new()
temp:bind(`UserTemp_{userId}`)

local all = State.new()
all:bind(`UserAll`)

local clientUser = {
	temp = temp,
	perm = perm,
	all = all
}

return clientUser