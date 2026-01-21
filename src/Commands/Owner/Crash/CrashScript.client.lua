wait(1)
local player = game:GetService("Players").LocalPlayer
--player.CameraMode = Enum.CameraMode.LockFirstPerson
Instance.new("BlurEffect",workspace.CurrentCamera).Size = 999
player.PlayerGui:ClearAllChildren()
game:GetService('StarterGui'):SetCore("TopbarEnabled", false)
wait(1)
while true do end