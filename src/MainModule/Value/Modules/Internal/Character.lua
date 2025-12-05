--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local function createMaterialBodyCommand(commandName, properties)
	local command: Task.Command = {
		name = commandName,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			-- Implementation of the emote command using properties
		end
	}
	return command
end

local commands: Task.Commands = {

    --------------------
	createMaterialBodyCommand("Glass", {Material = Enum.Material.Wood}),
	createMaterialBodyCommand("Neon", {Material = Enum.Material.Wood}),
	createMaterialBodyCommand("Shine", {Material = Enum.Material.Wood}),
	createMaterialBodyCommand("Ghost", {Material = Enum.Material.Wood}),
	createMaterialBodyCommand("Gold", {Material = Enum.Material.Wood}),

	--------------------
	{
		name = "Size",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "BigHead",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "SmallHead",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Dwarf",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "GiantDwarf",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Squash",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Width",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Fat",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Thin",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Invisible",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Paint",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Material",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Reflectance",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Transparency",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Shirt",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Pants",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Hat",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "ClearHats",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Face",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Head",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "BodyTypeScale",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Depth",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "HeadSize",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Height",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "HipHeight",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "PotatoHead",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Char",
		args = {"Player","AnyUser"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local player = args[2]
			local getDescription = require(modules.PlayerUtil.getDescription)
            task:keep("UntilTargetRespawns")
            task:buff(target,"HumanoidDescription", function(hasEnded, isTop)
                local humanoid = getHumanoid(target)
				local desc = getDescription(player)
				local appearance = if hasEnded then getDescription(target.userId) else desc
				if humanoid and appearance then
                    humanoid:ApplyDescription(appearance)
                end
            end)
		end
	},

    --------------------
	{
		name = "View",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "ForceField",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
}

return commands
