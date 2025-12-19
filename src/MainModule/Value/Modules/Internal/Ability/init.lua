--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHead = require(modules.PlayerUtil.getHead)
local getHRP = require(modules.PlayerUtil.getHRP)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "Spin",
		args = {"Player", "Number"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 14
			local head = getHead(target)
			if not head then return end
			task:keep("UntilTargetRespawns")
			local spin1 = task.janitor:add(Instance.new("BodyAngularVelocity"))
			spin1.MaxTorque = Vector3.new(300000, 300000, 300000)
			spin1.P = 300
			spin1.Parent = head
			local spin2 = task.janitor:add(Instance.new("BodyGyro"))
			spin2.MaxTorque = Vector3.new(400000, 0, 400000)
			spin2.D = 500
			spin2.P = 300
			spin2.Parent = head
			spin1.AngularVelocity = Vector3.new(0,number,0)
		end
	},

    --------------------
	{
		name = "ForceField",
		aliases	= {"FF"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local hrp = getHRP(target)
			if not hrp then return end
			task:keep("UntilTargetRespawns")
			local item = task.janitor:add(Instance.new("ForceField"))
			item.Parent = hrp.Parent
		end
	},

    --------------------
	{
		name = "Fire",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local hrp = getHRP(target)
			if not hrp then return end
			task:keep("UntilTargetRespawns")
			local item = task.janitor:add(Instance.new("Fire"))
			item.Parent = hrp
		end
	},

    --------------------
	{
		name = "Smoke",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local hrp = getHRP(target)
			if not hrp then return end
			task:keep("UntilTargetRespawns")
			local item = task.janitor:add(Instance.new("Smoke"))
			item.Parent = hrp
		end
	},

    --------------------
	{
		name = "Sparkles",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local hrp = getHRP(target)
			if not hrp then return end
			task:keep("UntilTargetRespawns")
			local item = task.janitor:add(Instance.new("Sparkles"))
			item.Parent = hrp
		end
	},

    --------------------
	{
		name = "Sit",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local humanoid = getHumanoid(target)
			if not humanoid then return end
			humanoid.Sit = true
		end
	},

    --------------------
	{
		name = "Jump",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local humanoid = getHumanoid(target)
			if not humanoid then return end
			humanoid.Jump = true
		end
	},

    --------------------
	{
		name = "NightVision",
		aliases = {"NV"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetLeaves")
			task.client:run(target)
		end
	},

    --------------------
	{
		name = "Respawn",
		aliases = {"Res"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local player: Player = unpack(args)
			local loadCharacter = require(modules.PlayerUtil.loadCharacter)
			loadCharacter(player)
		end
	},

    --------------------
	{
		name = "Warp",
		args = {"Player"},
		cooldown = 7.5,
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task.client:run(target)
		end
	},

    --------------------
	{
		name = "Blur",
		args = {"Player", "Number"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 20
			task:keep("UntilTargetLeaves")
			task.client:run(target, number)
		end
	},

    --------------------
	{
		name = "Anchor",
		aliases = {"Freeze"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local setAnchored = require(modules.AssetUtil.setAnchored)
			task:keep("UntilTargetRespawns")
			setAnchored(target.Character, true)
			task:onEnded(function()
				setAnchored(target.Character, false)
			end)
		end
	},

    --------------------
	{
		name = "Name",
		aliases = {"FakeName"},
		args = {"Player", "Text"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local humanoid = getHumanoid(target)
			local text = task:getOriginalArg("Text")
			if not text or text == "" then
				text = "Example Fake Name"
			end
			if not humanoid then return end
			task:keep("UntilTargetRespawns")
			humanoid.DisplayName = text
			Prompt.info(target, `Updated display name to '{text}'`)
			task:onEnded(function()
				humanoid.DisplayName = target.Name
				Prompt.info(target, `Reset display name to '{target.Name}'`)
			end)
		end
	},

    --------------------
	{
		name = "HideName",
		undoAliases = {"ShowName"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local humanoid = getHumanoid(target)
			if not humanoid then return end
			task:keep("UntilTargetRespawns")
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			Prompt.info(target, `Your display name has been hidden from other players'`)
			task:onEnded(function()
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
				Prompt.info(target, `Your display name is now visible to other players`)
			end)
		end
	},

    --------------------
	
}
return commands