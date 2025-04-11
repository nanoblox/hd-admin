--!strict
local RunService = game:GetService("RunService")
return function(player: Player?, cframe: CFrame): (boolean, string)
	if not player then
		return false, "Missing player"
	end
	if RunService:IsClient() then
		return false, "teleportAsync must be called from server"
	end
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("HumanoidRootPart")
	player:RequestStreamAroundAsync(cframe.Position)
	character:PivotTo(cframe)
	return true, "Success"
end