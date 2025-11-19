--!strict
-- CONFIG
local DEFAULT_ROLE = {
	name = "UnnamedRole",
	displayName = "UnnamedRole",
	members = {""},
	rank = 1,
	modifiers = "",
	bypassLimits = false, -- This enables command cooldowns, batch size limits, etc to be bypassed when true, in addition to command-specific limits that are determined with task.bypassLimits
	modifiers = "",
	qualifiers = "",
}

local CLIENT_PROPERTIES_TO_EXCLUDE = {
	"members"
}

local CLIENT_PROPERTIES_TO_PREVIEW = {
	"name",
}


-- LOCAL
local Roles = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local User = require(modules.Objects.User)
local State = require(modules.Objects.State)
local Framework = require(modules.Framework)
local lowerCaseNameToRoles: State.Class = State.new(true)
local rolesOrdered: {Role} = {}
local rolesRequireUpdating = true


-- TYPES
export type Role = typeof(DEFAULT_ROLE)


-- FUNCTIONS
function Roles.updateRoles(forceUpdate: boolean?): boolean
	if not rolesRequireUpdating and not forceUpdate then
		return false
	end
	local newLowerCaseNameToRoles = {}
	rolesRequireUpdating = false
	rolesOrdered = {}

	-- Get role data from config
	-- (in the future, we'll also retrieve it from datastores)
	local configRoles = Framework.getInstance(modules.Config, "Roles")
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
				role.displayName = name
				role.name = nameLower
				for attName, attValue in configRole:GetAttributes() do
					local attNameCorrected = toCamelCase(attName)
					if not DEFAULT_ROLE[attNameCorrected] then
						continue
					end
					role[attNameCorrected] = attValue
				end
				table.insert(rolesOrdered :: any, role)
				newLowerCaseNameToRoles[nameLower] = role
				scanForRoles(configRole)
			end
		end
		scanForRoles(configRoles)
	end
	
	table.sort(rolesOrdered, function(a: Role, b: Role): boolean
		return a.rank > b.rank
	end)
	--!!! to-do: when lowerCaseNameToRoles is changed, also update everyone("Roles") and everyone("RoleInfo")
	--!!! but make sure to disconnect previous listeners first
	lowerCaseNameToRoles:setAll(newLowerCaseNameToRoles)
	User.everyone:set("Roles", rolesOrdered)
	User.everyone:set("RoleInfo", newLowerCaseNameToRoles)
	
	return true
end

function Roles.getRole(name: string): Role?
	Roles.updateRoles()
	local lowerName = name:lower()
	local role = lowerCaseNameToRoles:get(lowerName) :: Role?
	return role
end

function Roles.getRoles()
	Roles.updateRoles()
	return rolesOrdered
end

function Roles.getOwnedRolesDict(player)
	-- This takes roles from both temp and perm of a player's user, and collects
	-- them all together. This is recommended instead of checking perm and temp
	-- manually, as this covers potential changes to role storage in the future
	local ownedRolesDict = {}
	local user = User.getUser(player)
	if not user then
		return ownedRolesDict
	end
	local tempRoles = user.temp:get("Roles") or {}
	local permRoles = user.perm:get("Roles") or {}
	for _, roleName in tempRoles do
		ownedRolesDict[roleName] = true
	end
	for _, roleName in permRoles do
		ownedRolesDict[roleName] = true
	end
	return ownedRolesDict
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