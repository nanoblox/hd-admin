--!strict
-- LOCAL
local ClientVerify = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local Prompt = require(modules.Prompt)


-- SETUP
-- Plays sound on client
local joinHDGroup = Remote.get("JoinHDGroup")
joinHDGroup:onClientEvent(function(groupId: number, noticeText: string)
	local GroupService = game:GetService("GroupService")
	Prompt.info(noticeText)
	local success, result = pcall(function()
		return GroupService:PromptJoinAsync(groupId)
	end)
	if success and result ~= Enum.GroupMembershipStatus.None then
		joinHDGroup:fireServer("Successfully joined!")
		Prompt.success(noticeText)
	end
end)


return ClientVerify