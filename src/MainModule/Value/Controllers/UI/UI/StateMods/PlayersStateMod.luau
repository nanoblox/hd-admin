local Players = game:GetService("Players")

local HDAdminUI = script.Parent.Parent
local States = require(HDAdminUI.States)

local PlayersStateMod = {}

function PlayersStateMod.Update()
	States.Session.Players:set(Players:GetPlayers())
end

Players.PlayerAdded:Connect(function()
	PlayersStateMod.Update()
end)

Players.PlayerRemoving:Connect(function()
	PlayersStateMod.Update()
end)

PlayersStateMod.Update()

return PlayersStateMod
