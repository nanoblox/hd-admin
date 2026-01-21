--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Prompt = require(modules.Prompt)

return function(assetType: Enum.AssetType, task: Task.Class, integer: number, callback: (item: Instance) -> ())
	local typeName = assetType.Name
	if integer <= 0 then
		Prompt.error(task.caller, `Invalid {typeName}Id`)
		return
	end
	local config = task.config
	local caller = task.caller
	local isTypeAsync = require(modules.VerifyUtil.isTypeAsync)
	local verifyConfigLists = require(modules.VerifyUtil.verifyConfigLists)
	local success, newIdOrWarning = verifyConfigLists(caller, config, integer)
	if not success then
		Prompt.error(caller, tostring(newIdOrWarning))
		return
	end
	if newIdOrWarning == integer and not isTypeAsync(integer, assetType) then
		Prompt.error(caller, `ID is not a {typeName} Asset`)
		return
	end
	if newIdOrWarning ~= integer then
		integer = newIdOrWarning :: number
		Prompt.info(caller, `{typeName}Id {integer} was replaced with {newIdOrWarning} by the game's developer`)
	end
	local AssetService = game:GetService("AssetService")
	local success, assetOrWarning = pcall(function()
		return AssetService:LoadAssetAsync(integer)
	end)
	if not success or typeof(assetOrWarning) ~= "Instance" then
		Prompt.error(caller, `Failed to load {typeName} {integer}: {assetOrWarning}`)
		return
	end
	local item = assetOrWarning:GetChildren()[1]
	if not item then
		Prompt.error(caller, `No item found in {typeName} Asset`)
		assetOrWarning:Destroy()
		return
	end
	callback(item)
	assetOrWarning:Destroy()
end