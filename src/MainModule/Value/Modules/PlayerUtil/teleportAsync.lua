--!strict
local RunService = game:GetService("RunService")
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
	player:RequestStreamAroundAsync(cframe.Position)
	character:PivotTo(cframe)
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end
	return true, "Success"
end