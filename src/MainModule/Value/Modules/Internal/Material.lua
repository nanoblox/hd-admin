--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local getHead = require(modules.PlayerUtil.getHead)
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local applyDescription = require(modules.OutfitUtil.applyDescription)
local setTransparency = require(modules.AssetUtil.setTransparency)
local setFakeBodyParts = require(modules.OutfitUtil.setFakeBodyParts)
local clearFakeBodyParts = require(modules.OutfitUtil.clearFakeBodyParts)


-- LOCAL FUNCTIONS
local function createMaterialBodyCommand(commandName, properties)
	local command: Task.Command = {
		name = commandName,
		groups = {"Material"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			setFakeBodyParts(target.Character, properties)
			task:onEnded(function() 
				clearFakeBodyParts(target.Character)
			end)
		end
	}
	return command
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	createMaterialBodyCommand("Glass", {Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.Glass, Transparency = 0.5}),
	createMaterialBodyCommand("Neon", {Color = Color3.fromRGB(180, 180, 180), Material = Enum.Material.Neon, Transparency = 0}),
	createMaterialBodyCommand("Shine", {Reflectance = 0, Material = Enum.Material.Neon, Transparency = 0.5}),
	createMaterialBodyCommand("Ghost", {Reflectance = 0, Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.SmoothPlastic, Transparency = 0.7}),
	createMaterialBodyCommand("Gold", {Reflectance = 0.5, Color = Color3.fromRGB(255, 176, 0), Material = Enum.Material.SmoothPlastic, Transparency = 0}),
	
	--------------------
	{
		name = "Reflect",
		aliases	= {"Ref", "Shiny", "Reflectance"},
		groups = {"Material"},
		args = {"Player", "Number"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 1
			task:keep("UntilTargetRespawns")
			setFakeBodyParts(target.Character, {Reflectance = number})
			task:onEnded(function() 
				clearFakeBodyParts(target.Character)
			end)
		end
	},

    --------------------
	{
		name = "Material",
		aliases	= {"Mat", "Surface"},
		groups = {"Material"},
		args = {"Player", "Material"},
		run = function(task: Task.Class, args: {any})
			local target, material = unpack(args)
			task:keep("UntilTargetRespawns")
			setFakeBodyParts(target.Character, {Material = material})
			task:onEnded(function() 
				clearFakeBodyParts(target.Character)
			end)
		end
	},

    --------------------
	{
		name = "Paint",
		aliases	= {"Color","Colour"},
		args = {"Player", "Color"},
		run = function(task: Task.Class, args: {any})
			local target, color = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", function(hasEnded, originalValue)
				local humanoid = getHumanoid(target)
				if not humanoid then return end
				local originalDesc = (originalValue or humanoid:GetAppliedDescription()) :: any
				if hasEnded then
					applyDescription(humanoid, originalDesc)
				else
					applyDescription(humanoid, originalValue, {
						HeadColor = color,
						LeftArmColor = color,
						RightArmColor = color,
						LeftLegColor = color,
						RightLegColor = color,
						TorsoColor = color,
					})
				end
				return originalDesc
			end)
		end
	},

    --------------------
	{
		name = "Transparency",
		aliases = {"Trans"},
		groups = {"Material"},
		args = {"Player", "Number"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 0.5
			task:keep("UntilTargetRespawns")
			task:buff(target, "Transparency", function(isEnded, originalValue)
				local head = getHead(target)
				if not head then return 0 end
				local char = target.Character
				local original = (originalValue or head.Transparency) :: number
				local value = if isEnded then original else number
				setTransparency(char, value)
				return original
			end)
		end
	},

    --------------------
	{
		name = "Invisible",
		aliases = {"Invis"},
		undoAliases = {"Visible", "Vis"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = 1
			task:keep("UntilTargetRespawns")
			task:buff(target, "Transparency", function(isEnded, originalValue)
				local head = getHead(target)
				if not head then return 0 end
				local char = target.Character
				local original = (originalValue or head.Transparency) :: number
				local value = if isEnded then original else number
				setTransparency(char, value)
				return original
			end)
		end
	},

    --------------------
}

return commands
