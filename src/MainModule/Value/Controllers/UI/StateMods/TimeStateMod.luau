local RunService = game:GetService("RunService")

local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local States = require(UI.States)

local TimeStateMod = {
	Updater = RunService.RenderStepped:Connect(function()
		States.UnixTime:set(DateTime.now().UnixTimestampMillis)
	end),
}

function TimeStateMod:Stop()
	TimeStateMod.Updater:Disconnect()
end

return TimeStateMod
