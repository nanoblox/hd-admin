-- Useful for code which will be accessed by both server and client
local modules = script:FindFirstAncestor("MainModule").Value.Modules
return function(newSubject: Instance)
	if typeof(newSubject) ~= "Instance" then
		return
	end
	if newSubject:IsA("Player") then
		local getHumanoid = require(modules.PlayerUtil.getHumanoid)
		local humanoid = getHumanoid(newSubject)
		if not humanoid then
			return
		end
		newSubject = humanoid
	end
	local camera = workspace.CurrentCamera
	camera.CameraSubject = newSubject
end