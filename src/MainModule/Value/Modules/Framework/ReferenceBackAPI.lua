--!nocheck
-- This is for modules located within server Config that need to reference back to Shared config
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hd = ReplicatedStorage:FindFirstChild("HD Admin")
local originalAPI = hd.Core.API
return require(originalAPI)