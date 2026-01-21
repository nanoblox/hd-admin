--!strict
-- CONFIG
local ORDER = 450
local ROLES = {script.Parent.Name, "Build"}
local SAVE_MAP_ON_START = false -- Set to true if you'd like to be able to call ;loadMap without having to call ;saveMap first


-- LOCAL
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Teams = game:GetService("Teams")
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local ServerStorage = game:GetService("ServerStorage")
local mapBackupFolder = Instance.new("Folder")
local Prompt = require(modules.Prompt)
local backupTerrain: any = nil
local Players = game:GetService("Players")


-- LOCAL FUNCTIONS
local function forEveryValidWorkspaceChild(callback: (part: Instance) -> ())
	local playerNames = {}
	for _, player in Players:GetPlayers() do
		playerNames[player.Name] = true
	end
	for _, instance in workspace:GetChildren() do
		if instance:IsA("Terrain") then
			continue
		end
		if not instance.Archivable then
			continue
		end
		local lowerName = instance.Name:lower()
		if lowerName:match("hd admin") or lowerName:match("hdadmin") then
			continue
		end
		if instance:IsA("Script") then
			continue
		end
		if instance:IsA("Model") and playerNames[instance.Name] then
			continue
		end
		callback(instance)
	end
end

local function saveMap(caller: Player?)
	Prompt.info(caller, "Saving copy of map...")
	if not mapBackupFolder.Parent then
		mapBackupFolder.Name = "HDAdminMapBackup"
		mapBackupFolder.Parent = ServerStorage
	end
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	backupTerrain = terrain and terrain:CopyRegion(terrain.MaxExtents)
	mapBackupFolder:ClearAllChildren()
	forEveryValidWorkspaceChild(function(instance)
		instance:Clone().Parent = mapBackupFolder
	end)
	Prompt.success(caller, "Map saved!")
end


-- SETUP
if SAVE_MAP_ON_START then
	task.defer(function()
		saveMap()
	end)
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "SaveMap",
		aliases = {"BackupMap"},
		roles = ROLES,
		order = ORDER,
		args = {},
		cooldown = 3,
		run = function(task: Task.Class, args: {any})
			saveMap(task.caller)
		end
	},

    --------------------
	{
		name = "LoadMap",
		aliases = {"RestoreMap"},
		roles = ROLES,
		order = ORDER,
		args = {},
		cooldown = 3,
		run = function(task: Task.Class, args: {any})
			local caller = task.caller
			if not mapBackupFolder.Parent then
				Prompt.error(caller, "No backup found: Use ;saveMap first, or set SAVE_MAP_ON_START within Commands/Admin/Map to true")
				return
			end
			if caller then
				Prompt.info(caller, "Restoring map...")
			end
			forEveryValidWorkspaceChild(function(instance)
				instance:Destroy()
			end)
			if backupTerrain then
				local terrain = workspace:FindFirstChildOfClass("Terrain")
				if terrain then
					terrain:Clear()
					terrain:PasteRegion(backupTerrain, terrain.MaxExtents.Min, true)
				end
			end
			local mapBackupClone = mapBackupFolder:Clone()
			mapBackupClone.Parent = workspace
			for _, instance in mapBackupClone:GetChildren() do
				instance.Parent = workspace
			end
			mapBackupClone:Destroy()
			if caller then
				Prompt.success(caller, "Map restored!")
			end
		end
	},

    --------------------
	{
		name = "LockMap",
		description = "Locks all parts in workspace, preventing players from selecting and editing parts",
		roles = ROLES,
		order = ORDER,
		args = {},
		run = function(task: Task.Class, args: {any})
			task:keep("Indefinitely")
			for _, instance in workspace:GetDescendants() do
				if instance:IsA("BasePart") then
					instance.Locked = true
					task:onEnded(function()
						instance.Locked = false
					end)
				end
			end
		end
	},

    --------------------
	{
		name = "LockCharacter",
		aliases = {"LockChar", "LockPlayer", "LockPlr", "LockP"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		description = "Locks all parts with the specified player",
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local char = target and target.Character
			if not char then return end
			task:keep("UntilTargetRespawns")
			for _, instance in char:GetDescendants() do
				if instance:IsA("BasePart") then
					instance.Locked = true
					task:onEnded(function()
						instance.Locked = false
					end)
				end
			end
		end
	},

    --------------------
	{
		name = "CreateTeam",
		aliases = {"CTeam"},
		roles = ROLES,
		order = ORDER,
		args = {"Color", "Text"},
		run = function(task: Task.Class, args: {any})
			local color: Color3, text = unpack(args)
			local team = Instance.new("Team")
			if text == "" or text == " " then
				text = "Unnamed"
			end
			team.TeamColor = BrickColor.new(color)
			team.Name = text
			team.AutoAssignable = false
			team.Parent = Teams
		end
	},

    --------------------
	{
		name = "RemoveTeam",
		aliases = {"RTeam"},
		roles = ROLES,
		order = ORDER,
		args = {"Team"},
		run = function(task: Task.Class, args: {any})
			local team = unpack(args)
			if team then
				team:Destroy()
			end
		end
	},

    --------------------
	
}


return commands