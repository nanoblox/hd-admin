--!strict
local RunService = game:GetService("RunService")
local modules = script:FindFirstAncestor("MainModule").Value.Modules

local function unseatPlayer(player)
	local getHumanoid = require(modules.PlayerUtil.getHumanoid)
	local humanoid = getHumanoid(player)
	if not humanoid then
		return
	end
	local seatPart = humanoid.SeatPart
	if not seatPart then
		return
	end
	local seatWeld = seatPart:FindFirstChild("SeatWeld")
	if not seatWeld then
		return
	end
	seatWeld:Destroy()
	task.wait()
end

return function(player: Player?, cframe: CFrame): (boolean, string)
	if not cframe then
		return false, "Missing CFrame"
	end
	if not player then
		return false, "Missing player"
	end
	if RunService:IsClient() then
		return false, "teleportAsync must be called from server"
	end
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart") :: any
	unseatPlayer(player)
	player:RequestStreamAroundAsync(cframe.Position)
	character:PivotTo(cframe)
	if hrp then
		-- This is to stop any momentum if for example the character is falling
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end
	return true, "Success"
end