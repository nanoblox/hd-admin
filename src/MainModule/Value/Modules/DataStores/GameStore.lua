-- !strict
-- LOCAL
local dataTemplates = require(script.Parent)
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local User = require(modules.Objects.User)
local DataStore = {}


-- PUBLIC
DataStore.dataStoreName = dataTemplates.dataStoreName
DataStore.dataKeyFormatter = `HD/{script.Name}/%s`
DataStore.compressData = false


-- FUNCTIONS
function DataStore.generateTemplate(user: User.Class?)
	if user then
		user.beforeSaving:Connect(function()
			
		end)
	end

	return {

		-- Data that is private and saved
		{"perm", {
			
		}},

		-- Data that is private but not saved
		{"temp", {
			
		}},

	}
end


return DataStore