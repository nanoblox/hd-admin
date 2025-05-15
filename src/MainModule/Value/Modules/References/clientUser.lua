local main = script:FindFirstAncestor("MainModule")
local State = require(main.Value.Modules.Objects.State)

local perm = State.new()
perm:bind(`UserPerm`)

local temp = State.new()
temp:bind(`UserTemp`)

local everyone = State.new()
everyone:bind(`UserEveryone`)

local clientUser = {
	temp = temp,
	perm = perm,
	everyone = everyone
}

return clientUser