-- A tiny security feature which checks if a player's account meets the minimum amount of days to join.
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Settings = require(modules.Config.Settings)
local minAccAge = Settings.SystemSettings.AccountCreationCheck

local function checkAccountAge(plr)
  if plr.Name ~= "Player" then
    if plr.AccountAge < minAccAge then
      plr:Kick("⛔️ Your account is too new to play the game! ⛔️")
      return false
    end
  end
end)

Players.PlayerAdded:Connect(function(plr)
  checkAccountAge(plr)
end)
