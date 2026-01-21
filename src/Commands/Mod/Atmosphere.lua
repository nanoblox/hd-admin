--!strict
local ORDER = 270
local ROLES = {script.Parent.Name, "Ability"}
local Lighting = game:GetService("Lighting")
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Time",
		aliases	= {"ClockTime","CT","TimeOfDay", "TOD"},
		roles = ROLES,
		order = ORDER,
		args = {"Number"},
		run = function(task: Task.Class, args: {any})
			local number = unpack(args)
			local originalTime = Lighting.ClockTime
			task:keep("Indefinitely")
			Lighting.ClockTime = number
			task:onEnded(function()
				Lighting.ClockTime = originalTime
			end)
		end
	},
	
    --------------------
	{
		name = "Fog",
		roles = ROLES,
		order = ORDER,
		args = {"Number"},
		run = function(task: Task.Class, args: {any})
			local number = task:getOriginalArg("Number") or 100
			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			task:keep("Indefinitely")
			if atmosphere then
				atmosphere.Parent = nil
				task:onEnded(function()
					atmosphere.Parent = Lighting
				end)
			end
			task:tween(Lighting, TweenInfo.new(2), {
				FogEnd = number
			})
			task:onEnded(function()
				Lighting.FogEnd = 100000
			end)
		end
	},

    --------------------
	{
		name = "FogColor",
		roles = ROLES,
		order = ORDER,
		args = {"Color"},
		run = function(task: Task.Class, args: {any})
			local color = unpack(args)
			local originalColor = Lighting.FogColor
			task:keep("Indefinitely")
			task:tween(Lighting, TweenInfo.new(2), {
				FogColor = color
			})
			task:onEnded(function()
				Lighting.FogColor = originalColor
			end)
		end
	},

    --------------------
	{
		name = "Disco",
		roles = ROLES,
		order = ORDER,
		args = {},
		run = function(task: Task.Class, args: {any})
			local TWEEN_INFO  = TweenInfo.new(1, Enum.EasingStyle.Linear)
			local propertiesToChange = {"Ambient", "OutdoorAmbient", "FogColor"}
			local originalAmbients = {}
			local targetHues = {3/3, 2/3, 1/3}
			task:keep("Indefinitely")
			for i,v in propertiesToChange do
				originalAmbients[v] = (Lighting :: any)[v]
			end
			while task.isActive do
				for i = 1, #targetHues do
					if not task.isActive then
						break
					end
					local targetValue = targetHues[i]
					local newPropValues = {}
					for i,v in pairs(propertiesToChange) do
						newPropValues[v] = Color3.fromHSV(targetValue, 1, 1)
					end
					local tween = task:tween(Lighting, TWEEN_INFO, newPropValues)
					tween.Completed:Wait()
					task.wait()
				end
			end
			task:onEnded(function()
				for propName, originalValue in originalAmbients do
					(Lighting :: any)[propName] = originalValue
				end
			end)
		end
	},

    --------------------
	
}
return commands