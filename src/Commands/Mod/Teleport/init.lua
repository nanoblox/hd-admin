--!strict
-- LOCAL
local ORDER = 340
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local teleportAsync = require(modules.PlayerUtil.teleportAsync)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHRP = require(modules.PlayerUtil.getHRP)
local getHead = require(modules.PlayerUtil.getHead)
local farlandBaseplate = nil :: any
local farlandCount = 0


-- LOCAL FUNCTIONS
local function teleportPlayers(playersToTeleport: {Player}, toPlayer: Player?)
	-- This could be improved in the future to account for each individual characters width
	local GAP = 2
	local totalPlrs = #playersToTeleport
	local targetHead = toPlayer and getHead(toPlayer)
	if not targetHead then
		return
	end
	for i, plr in playersToTeleport do
		if plr == toPlayer then
			continue
		end
		local head = getHead(plr)
		if not head then
			continue
		end
		local targetCFrame = targetHead.CFrame * CFrame.new(-(totalPlrs*(GAP/2))+(i*GAP)-(GAP/2), 0, -4) * CFrame.Angles(0, math.rad(180), 0)
		task.defer(function()
			teleportAsync(plr, targetCFrame)
		end)
	end
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "Teleport",
		aliases = {"TP"},
		roles = ROLES,
		order = ORDER,
		args = {"Players", "SinglePlayer"},
		run = function(task: Task.Class, args: {any})
			local players, toPlayer = unpack(args)
			teleportPlayers(players, toPlayer)
		end
	},

    --------------------
	{
		name = "Bring",
		aliases = {"Br"},
		roles = ROLES,
		order = ORDER,
		args = {"Players"},
		run = function(task: Task.Class, args: {any})
			local players = unpack(args)
			local toPlayer = task.caller
			teleportPlayers(players, toPlayer)
		end
	},

    --------------------
	{
		name = "To",
		aliases = {"GoTo"},
		roles = ROLES,
		order = ORDER,
		args = {"SinglePlayer"},
		run = function(task: Task.Class, args: {any})
			local singlePlayer = unpack(args)
			local callerPlayer = task.caller
			if singlePlayer and callerPlayer then
				teleportPlayers({callerPlayer}, singlePlayer)
			end
		end
	},

    --------------------
	{
		name = "Apparate",
		aliases = {"Ap", "Skip"},
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Distance"},
		run = function(task: Task.Class, args: {any})
			local target: Player = unpack(args)
			local targetHRP = getHRP(target)
			if not targetHRP then return end
			local distance = task:getOriginalArg("Distance") or 8
			local targetCFrame = targetHRP.CFrame * CFrame.new(0, 0, -distance)
			teleportAsync(target, targetCFrame)
		end
	},

	--------------------
	{
		name = "Farland",
		args = {"Player"},
		credit = {"MiIoshiee", "ForeverHD"},
		run = function(task: Task.Class, args: {any})

			-- This is the visible platform
			local target = unpack(args)
			local janitor = task.janitor
			local FARLAND_CFRAME = CFrame.new(993648,993648,993648)
			local baseplateCFrame = FARLAND_CFRAME + Vector3.new(0, -10, 0)
			if not farlandBaseplate then
				farlandBaseplate = require(script.baseplate)() :: any
				farlandBaseplate.Name = "HDAdminFarlandBaseplate"
				farlandBaseplate.CFrame = baseplateCFrame
				farlandBaseplate.Parent = workspace
			end
			farlandCount += 1
			janitor:add(function()
				farlandCount -= 1
				if farlandCount <= 0 and farlandBaseplate then
					farlandBaseplate:Destroy()
					farlandBaseplate = nil
				end
			end)

			-- This is the invisible platform
			local baseplateStand = janitor:add(farlandBaseplate:Clone())
			baseplateStand.Name = "HDAdminFarlandBaseplateStand"
			baseplateStand.CFrame = baseplateCFrame
			baseplateStand.Transparency = 1
			baseplateStand.Texture.Transparency = 1
			baseplateStand.Parent = workspace
			task.client:expose(target, baseplateStand)

			-- This handles teleportation
			task:keep("UntilTargetRespawns")
			task:buff(target, "Teleport", function(hasEnded, originalValue: any, isFirst)
				local hrp = getHRP(target)
				local originalCFrame = if hrp then hrp.CFrame else CFrame.new(0, 0, 0)
				local targetCFrame = if hasEnded then originalValue else FARLAND_CFRAME
				teleportAsync(target, targetCFrame)
				return originalCFrame
			end)

		end
	},
	--------------------
}
	

return commands
