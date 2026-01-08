--!strict
-- CONFIG
local DEFAULT_ROLE = {
	
	hide = false,
	key = "unnamedrole",
	name = "UnnamedRole",
	
	giveToEveryone = false,
	giveToFriends = false,
	giveToGroupRoles = "",
	giveToGroups = "",
	giveToPasses = "",
	giveToPrivateServerOwner = false,
	giveToUsers = "",

	limitCommandsPerMinute = 60,
	limitRequestsPerSecond = 10,

	mayEditAll = false, -- When true, users can edit everything, including roles above them
	mayEditGameSettings = false, -- When true, users can edit game settings, such as the default prefix, default interface presets, command colors, etc
	mayEditRoles = false, -- When true, users can create, edit, and delete roles below their rank. 'mayEditAll' is required to edit the same or higher roles, *and* to edit role permissions which their own role permissions don't have
	mayEditTasks = false, -- When true, users can pause, resume and cancel any task within tasks

	mayViewAll = false,
	mayViewAnalytics = false,
	mayViewBans = false,
	mayViewCommands = true,
	mayViewCommandsIcon = true, -- When true, displays the commands icon which opens solely the commands page
	mayViewDashboardIcon = false, -- When true, overrides mayViewCommandsIcon, and displays the dashboard icon (the main HD icon)
	mayViewGameSettings = false,
	mayViewLogs = false,
	mayViewMembers = false,
	mayViewRoles = false,
	mayViewTasks = false,
	mayViewUnavailableCommands = false,
	mayViewWarns = false,
	mayViewYouSettings = true,

	permitAll = false,
	permitBypassLimits = false, -- When true, users can bypass limits across all commands and arguments
	permitModifiersAbusive = false, -- When true, users can use potentially abusive modifiers like 'loop' and 'delay'
	permitModifiersGlobal = false, -- When true, users can can broadcast any useable command to all servers with modifiers like 'global' and 'perm'. Be VERY careful about who you permit this to!
	permitMultipleTargets = true, -- When true, users can target multiple people at once with commands (e.g. ;kill others)
	permitTargetingOthers = true, -- When true, users can run commands on players other than themselves
	permitCommandInheritence = false, -- When true, users can run commands that are permitted for roles below this role
	
	promptAll = false, -- Displays all prompts
	promptWarnings = false, -- Displays warning notices (such as 'Invalid prefix! Try using [correctPrefix] instead!', '[CommandName] is not a valid command!', 'You do not have permission to use this command', etc)
	promptWelcome = false, -- Displays welcome notices (such as 'You're a [highestRoleName]', etc)

	rank = 1,
}

local CLIENT_PROPERTIES_TO_EXCLUDE = {
	"members"
}

local CLIENT_PROPERTIES_TO_PREVIEW = {
	"key",
	"name",
	"hide",
}


-- LOCAL
local Roles = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local User = require(modules.Objects.User)
local State = require(modules.Objects.State)
local Framework = require(modules.Framework)
local keyToRole: State.Class = State.new(true)
local rolesOrdered: {Role} = {}
local rolesRequireUpdating = true


-- TYPES
export type Role = typeof(DEFAULT_ROLE)


-- FUNCTIONS
function Roles.updateRoles(forceUpdate: boolean?): boolean
	if not rolesRequireUpdating and not forceUpdate then
		return false
	end
	local newKeyToRole = {}
	rolesRequireUpdating = false
	rolesOrdered = {}

	-- Get role data from config
	-- (in the future, we'll also retrieve it from datastores)
	local configRoles = Framework.getInstance(modules.Parent.Services.Config, "Roles")
	local deepCopyTable = require(modules.TableUtil.deepCopyTable)
	if configRoles then
		local toCamelCase = require(modules.DataUtil.toCamelCase)
		local function scanForRoles(instanceToScan: Instance)
			for _, configRole in instanceToScan:GetChildren() do
				if not configRole:IsA("Configuration") then
					continue
				end
				local name = configRole.Name
				local nameLower = name:lower()
				local role = deepCopyTable(DEFAULT_ROLE) :: any
				role.name = name
				role.key = nameLower
				for attName, attValue in configRole:GetAttributes() do
					local attNameCorrected = toCamelCase(attName)
					if not DEFAULT_ROLE[attNameCorrected] then
						continue
					end
					role[attNameCorrected] = attValue
				end
				table.insert(rolesOrdered :: any, role)
				newKeyToRole[nameLower] = role
				scanForRoles(configRole)
			end
		end
		scanForRoles(configRoles)
	end
	
	table.sort(rolesOrdered, function(a: Role, b: Role): boolean
		return a.rank > b.rank
	end)
	--!!! to-do: when keyToRole is changed, also update everyone("Roles") and everyone("RoleInfo")
	--!!! but make sure to disconnect previous listeners first
	keyToRole:setAll(newKeyToRole)
	User.everyone:set("Roles", rolesOrdered)
	User.everyone:set("RoleInfo", newKeyToRole)
	
	return true
end

function Roles.getRole(name: string): Role?
	Roles.updateRoles()
	local lowerName = name:lower()
	local role = keyToRole:get(lowerName) :: Role?
	return role
end

function Roles.getRoles()
	Roles.updateRoles()
	return rolesOrdered
end

function Roles.getOwnedRoles(user: User.Class?): ({string}, {[string]: boolean})
	-- This takes roles from both temp and perm of a player's user, and collects
	-- them all together. This is recommended instead of checking perm and temp
	-- manually, as this covers potential changes to role storage in the future
	if not user then
		return {}, {}
	end
	local ownedRolesDict = {}
	local tempRoles = user.temp:get("Roles") or {}
	local permRoles = user.perm:get("Roles") or {}
	for _, roleName in tempRoles do
		ownedRolesDict[roleName] = true
	end
	for _, roleName in permRoles do
		ownedRolesDict[roleName] = true
	end
	local ownedRolesArray = {}
	for roleName, _ in ownedRolesDict do
		table.insert(ownedRolesArray, roleName)
	end
	return ownedRolesArray, ownedRolesDict
end


-- SETUP
-- These set restrictions on what the client can see, and which clients
local getStateVerifier = require(modules.VerifyUtil.getStateVerifier)
User.everyone:verify(getStateVerifier(
	"Roles",
	"OnlyInclude",
	CLIENT_PROPERTIES_TO_PREVIEW
))
User.everyone:verify(getStateVerifier(
	"RoleInfo",
	"Exclude",
	CLIENT_PROPERTIES_TO_EXCLUDE
))

-- This is essential to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.verifyFirstFetch("Roles", Roles.updateRoles)
State.verifyFirstFetch("RoleInfo", Roles.updateRoles)


return Roles