--[[

	Qualifiers are terms that describe what pool of players should be returned
	For example, "All", returns all players in the server, while "Me" only returns you.
	It's important to note: the caller (i.e. the person who executed the command), might
	not actually be from *this server* (for example, due to global executions), so it's
	important to only use the callerUserId and to remember that they may not have an
	associated Player instance.

]]


--!strict
-- LOCAL
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Qualifiers = {}
local User = require(modules.Objects.User)
local requiresUpdating = true
local sortedNameAndAliasLengthArray = {}
local lowerCaseDictionary = {}


-- LOCAL FUNCTIONS
local function register(item: QualifierDetail): QualifierDetail
	return item :: QualifierDetail -- We do this to support type checking within the table
end


-- FUNCTIONS
function Qualifiers.update()
	if not requiresUpdating then
		return false
	end
	requiresUpdating = false
	local allItems = Qualifiers.getAll()
	sortedNameAndAliasLengthArray = {}
	lowerCaseDictionary = {}
	for itemNameOrAlias, item in pairs(allItems :: any) do
		local lowerCaseName = tostring(itemNameOrAlias):lower()
		lowerCaseDictionary[lowerCaseName] = item
		table.insert(sortedNameAndAliasLengthArray, tostring(itemNameOrAlias))
	end
	table.sort(sortedNameAndAliasLengthArray, function(a: string, b: string): boolean
		return #a > #b
	end)
	return true
end

function Qualifiers.getSortedNameAndAliasLengthArray()
	Qualifiers.update()
	return sortedNameAndAliasLengthArray
end

function Qualifiers.getLowercaseDictionary()
	Qualifiers.update()
	return lowerCaseDictionary
end

function Qualifiers.get(qualifierName: Qualifier): QualifierDetail?
	local qualifierNameLower = tostring(qualifierName):lower()
	local ourDictionary = Qualifiers.getLowercaseDictionary()
	local item = ourDictionary[qualifierNameLower] :: QualifierDetail?
	if not item then
		return nil
	end
	local qualifierNameCorrected = item.name
	if item.mustBecomeAliasOf then
		local toBecomeName = item.mustBecomeAliasOf
		local qualifierToBecome = Qualifiers.items[toBecomeName]
		if not qualifierToBecome then
			error(`Qualifiers: {qualifierNameCorrected} can not become alias because {toBecomeName} is not a valid qualifier`)
		end
		qualifierToBecome = qualifierToBecome :: any
		for k,v in qualifierToBecome do
			if not item[k] then
				item[k] = v
			end
		end
		item.mustBecomeAliasOf = nil :: any
		item.aliasOf = toBecomeName
	end
	return item :: QualifierDetail
end

function Qualifiers.getAll()
	-- We call .get to ensure all aliases are registered and setup correctly
	local items = Qualifiers.items :: {[string]: QualifierDetail}
	for qualifierName, item in items do
		if not item.name then
			item.name = qualifierName
		end
		Qualifiers.get(qualifierName :: Qualifier)
	end
	return items
end

function Qualifiers.becomeAliasOf(qualifierName: Qualifier, initialTable: any?)
	-- We don't actually create a mirror table here as the data of items will have
	-- not yet gone into memory. Instead, we record the table as an alias, then
	-- set it's data once .get is called or 
	task.defer(function()
		-- This servers as a warning as opposed to an actual error
		if not Qualifiers.items[qualifierName] then
			error(`Qualifiers: {qualifierName} is not a valid qualifier`)
		end
	end)
	if typeof(initialTable) ~= "table" then
		initialTable = {}
	end
	initialTable.mustBecomeAliasOf = qualifierName
	return initialTable
end


-- PUBLIC
Qualifiers.items = {
	
	["Default"] = register({
		isHidden = true,
		description	= "Default action, returns players with matching shorthand names.",
		getTargets = function(callerUserId, stringToParse, useDisplayName)
			local ParserUtility = require(script.Parent.ParserUtility)
			local callerUser = User.getUser(callerUserId)
			local targets = ParserUtility.getPlayersFromString(stringToParse :: string, callerUser)
			return targets
		end,
	}),
	["Me"] = register({
		description = "You!",
		getTargets = function(callerUserId: number)
			local targets: {Player} = {}
			local callerPlayer = Players:GetPlayerByUserId(callerUserId)
			if callerPlayer then
				table.insert(targets, callerPlayer)
			end
			return targets
		end,
	}),

	["All"] = register({
		description = "Every player in a server.",
		getTargets = function()
			return Players:GetPlayers()
		end,
	}),

	["Random"] = register({
		description = "One randomly selected player from a pool. To define a pool, do ``random(qualifier1,qualifier2,...)``. If not defined, the pool defaults to 'all'.",
		getTargets = function(callerUserId, ...)
			local subQualifiers = {...}
			if #subQualifiers == 0 then
				table.insert(subQualifiers, "all")
			end
			local pool = {}
			for _, subQualifier in (subQualifiers) do
				local qualifier = Qualifiers.get(subQualifier) or Qualifiers.get("Default")
				local subPool = qualifier and qualifier.getTargets(callerUserId, subQualifier)
				if subPool then
					for _, plr in (subPool) do
						table.insert(pool, plr)
					end
				end
			end
			local totalPool = #pool
			local targets = {}
			if totalPool > 0 then
				targets = {pool[math.random(1, #pool)]}
			end
			return targets
		end,
	}),

	["Others"] = register({
		description = "Every player except you.",
		getTargets = function(callerUserId)
			local targets = {}
			for _, plr in (Players:GetPlayers()) do
				if plr.UserId ~= callerUserId then
					table.insert(targets, plr)
				end
			end
			return targets
		end,
	}),

	["Radius"] = register({
		description = "Players within x amount of studs from you. To specify studs, do ``radius(studs)``. If not defined, studs defaults to '10'.",
		getTargets = function(callerUserId, radiusString)
			local targets = {}
			local radius = tonumber(radiusString) or 10
			local callerPlayer = Players:GetPlayerByUserId(callerUserId)
			local getHeadPos = require(modules.Utility.PlayerUtil.getHeadPos)
			if callerPlayer then
				local callerHeadPos = getHeadPos(callerPlayer) or Vector3.new(0, 0, 0)
				for _, plr in (Players:GetPlayers()) do
					if plr:DistanceFromCharacter(callerHeadPos) <= radius then
						table.insert(targets, plr)
					end
				end
			end
			return targets
		end,
	}),

	["Team"] = register({
		description = "Players within the specified team(s).",
		getTargets = function(_, ...)
			local targets = {}
			local teamNames = table.pack(...)
			local selectedTeams = {}
			local validTeams = false
			if #teamNames == 0 then
				return {}
			end
			for _, team in (Teams:GetChildren()) do
				team = team :: Team
				local teamName = string.lower(team.Name)
				for _, selectedTeamName in (teamNames) do
					if string.sub(teamName, 1, #selectedTeamName) == selectedTeamName then
						selectedTeams[tostring(team.TeamColor)] = true
						validTeams = true
					end
				end
			end
			if not validTeams then
				return {}
			end
			for i, plr in (Players:GetPlayers()) do
				if selectedTeams[tostring(plr.TeamColor)] then
					table.insert(targets, plr)
				end
			end
			return targets
		end,
	}),

	["Group"] = register({
		description	= "Players who are in the specified Roblox groupIds(s).",
		getTargets = function(_, ...)
			local targets = {}
			local groupIds = {}
			for _, groupId in (table.pack(...)) do
				groupId = tonumber(groupId)
				if groupId then
					table.insert(groupIds, groupId)
				end
			end
			for _, plr in (Players:GetPlayers()) do
				for _, groupId in (groupIds) do
					if plr:IsInGroup(groupId) then
						table.insert(targets, plr)
						break
					end
				end
			end
			return targets
		end,
	}),

	["Role"] = register({
		description = "Players who have the specified role(s).",
		getTargets = function(_, ...)
			local targets = {}
			local roleNames = table.pack(...)
			local selectedRoleKeys = {}
			if #roleNames == 0 then
				return {}
			end
			local Roles = require(modules.Roles)
			local roles = Roles.getRoles()
			for _, role in roles do
				local roleName = string.lower(role.name)
				local roleKey = role.key
				for _, selectedRoleName in (roleNames) do
					local nameMatch = string.sub(roleName, 1, #selectedRoleName) == selectedRoleName
					local keysMatch = roleKey == selectedRoleName
					if nameMatch or keysMatch then
						table.insert(selectedRoleKeys, roleKey)
					end
				end
			end
			if #selectedRoleKeys == 0 then
				return {}
			end
			local users = User.getUsers()
			for i, user in users do
				local function isValidUser()
					for _, roleUID in (selectedRoleKeys) do
						local roles = user.temp:get("Roles")
						if roles[roleUID] then
							return true
						end
					end
					return false
				end
				if isValidUser() and user.player then
					table.insert(targets, user.player)
				end
			end
			return targets
		end,
	}),

	["Percent"] = register({
		description = "Randomly selects x percent of players within a server. To define the percentage, do ``percent(number)``. If not defined, the percent defaults to '50'.",
		getTargets = function(_, percentString)
			local targets = {}
			local maxPercent = tonumber(percentString) or 50
			local players = Players:GetPlayers()
			local interval = 100 / #players
			if maxPercent >= (100 - (interval * 0.1)) then
				return players
			end
			local selectedPercent = 0
			repeat
				local randomIndex = math.random(1, #players)
				local selectedPlayer = players[randomIndex]
				table.insert(targets, selectedPlayer)
				table.remove(players, randomIndex)
			until #players == 0 or selectedPercent >= maxPercent
			return targets
		end,
	}),

	["Staff"] = register({
		description = "Selects all player's who are staff",
		getTargets = function(_)
			local targets = {}
			local users = User.getUsers()
			local isStaff = require(modules.Roles.isStaff)
			for i, user in users do
				if isStaff(user) and user.player then
					table.insert(targets, user.player)
				end
			end
			return targets
		end,
	}),

	["Admins"] = Qualifiers.becomeAliasOf("Staff"),
	
	["NonStaff"] = register({
		description = "Selects all player's who are not staff",
		getTargets = function(_)
			local targets = {}
			local users = User.getUsers()
			local isStaff = require(modules.Roles.isStaff)
			for i, user in users do
				if isStaff(user) == false and user.player then
					table.insert(targets, user.player)
				end
			end
			return targets
		end,
	}),

	["NonAdmins"] = Qualifiers.becomeAliasOf("NonStaff"),

	["Premium"] = register({
		description = "Players with Roblox Premium membership",
		getTargets = function(_)
			local targets = {}
			for _, player in (Players:GetPlayers()) do
				if player.MembershipType == Enum.MembershipType.Premium then
					table.insert(targets, player)
				end
			end
			return targets
		end,
	}),

	["Friends"] = register({
		description = "Players you are friends with",
		getTargets = function(callerUserId)
			local targets = {}
			for _, player in (Players:GetPlayers()) do
				if player:IsFriendsWith(callerUserId) then
					table.insert(targets, player)
				end
			end
			return targets
		end,
	}),
		--]]
}


-- TYPES
export type Qualifier = keyof<typeof(Qualifiers.items)>
export type QualifierDetail = {
	description: string?,
	getTargets: any, --(callerUserId: number?, stringToParse: string?, useDisplayName: boolean?) -> {Player},
	aliases: {[Qualifier]: boolean}?,
	isHidden: boolean?, -- Does this appear within the Commands Preview menu?
	mustBecomeAliasOf: any?,
	aliasOf: any?,
	name: any?,
}


return Qualifiers