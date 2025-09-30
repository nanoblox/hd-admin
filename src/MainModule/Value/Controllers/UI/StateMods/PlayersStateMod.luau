local Players = game:GetService("Players")

local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local States = require(UI.States)

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
