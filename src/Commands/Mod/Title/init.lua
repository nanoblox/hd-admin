--!strict
local EncodingService = game:GetService("EncodingService")
local ORDER = 250
local ROLES = {script.Parent.Name, "Prompt"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHead = require(modules.PlayerUtil.getHead)
local commands: Task.Commands = {

    --------------------
	{
		name = "Title",
		groups = {"Title"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local target, _, text = unpack(args)
			local head = getHead(target)
			if not head then return end
			local color = task:getOriginalArg("OptionalColor") or Color3.fromRGB(255,255,255)
			local janitor = task.janitor
			local h,s,v = color:ToHSV()
			local title = janitor:add(require(script.title)()) :: any
			task:keep("UntilTargetRespawns")
			title.Name = "HDAdminTitle"
			title.Parent = head
			title.TextLabel.Text = text
			title.TextLabel.TextColor3 = color
			title.TextLabel.TextStrokeColor3 = Color3.fromHSV(h, s, v*0.2)
		end
	},

    --------------------
	
}
return commands