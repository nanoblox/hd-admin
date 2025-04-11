-- !strict
-- LOCAL
local dataTemplates = require(script.Parent)
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local User = require(modules.Objects.User)
local DataStore = {}


-- PUBLIC
DataStore.dataStoreName = dataTemplates.dataStoreName
DataStore.dataKeyFormatter = `HD/{script.Name}/%s/Profile`
DataStore.compressData = false -- Compress data before saving (then decompress when loading) - this is worth it for large data sets, but may not be as preferable for small sets of data like PlayerData which is more useful to read


-- FUNCTIONS
function DataStore.generateTemplate(user: User.Class?)
	if user then
		user.beforeSaving:connect(function()
			local perm = user.perm
			local temp = user.temp
			local timeNow = os.time()
			local latestSession = temp:get("LatestSession")
			local timeElapsed = timeNow - latestSession
			temp:set("LatestSession", timeNow)
			perm:set("LastSession", timeNow)
			perm:update("TotalPlayTime", function(value)
				return value + timeElapsed
			end)
		end)
	end

	local timeNow = os.time()
	return {

		-- Data that is saved *and* retrievable by the client
		{"perm", "public", {
			Cash = 0,
		}},
		
		-- Data that is saved *but not* retrievable by the client
		{"perm", "private", {
			FirstSession = timeNow,
			LastSession = 0,
			TotalPlayTime = 0,
		}},

		-- Data that is not saved *but* retrievable by the client
		{"temp", "public", {
			PolicyInfo = {},
			Roles = {},
		}},

		-- Data that is not saved *and* not retrievable by the client
		{"temp", "private", {
			LatestSession = timeNow,
		}},

	}
end


return DataStore