local RunService = game:GetService("RunService")

local HDAdminUI = script.Parent.Parent
local States = require(HDAdminUI.States)

local TimeStateMod = {
	Updater = RunService.RenderStepped:Connect(function()
		States.UnixTime:set(DateTime.now().UnixTimestampMillis)
	end),
}

function TimeStateMod:Stop()
	TimeStateMod.Updater:Disconnect()
end

return TimeStateMod
