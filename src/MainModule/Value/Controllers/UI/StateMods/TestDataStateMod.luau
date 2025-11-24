local RunService = game:GetService("RunService")

local UserStateMod = require(script.Parent.UserStateMod)

local CHECK_EDIT = false

local TestDataStateMod = {}

task.spawn(function()
	if (not CHECK_EDIT) or (RunService:IsStudio()) then
		UserStateMod.Load(1)
		UserStateMod.Load(2)
		UserStateMod.Load(3)
	end
end)

return TestDataStateMod
