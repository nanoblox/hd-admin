-- !strict
-- LOCAL
local dataTemplates = require(script.Parent)
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local areValuesEqual = require(modules.DataUtil.areValuesEqual)
local deepCopyTable = require(modules.TableUtil.deepCopyTable)
local config = modules.Config
local configSettings = require(config.Settings)
local User = require(modules.Objects.User)
local DataStore = {}


-- PUBLIC
DataStore.dataStoreName = dataTemplates.dataStoreName
DataStore.dataKeyFormatter = `HD/{script.Name}/%s/Profile`
DataStore.compressData = false -- Compress data before saving (then decompress when loading) - this is worth it for large data sets, but may not be as preferable for small sets of data like PlayerData which is more useful to read


-- FUNCTIONS
function DataStore.generateTemplate(user: User.Class?)
	if user then
		user.beforeLoading:Connect(function()
			-- See if the game dev has changed settings, and if so, update the player's
			-- settings with these new values
			local perm = user.perm
			local playerSettings = perm:get("PlayerSettings")
			local previousPlayerSettings = perm:get("PreviousPlayerSettings")
			local gamePlayerSettings = configSettings.PlayerSettings
			local didChange = false
			local function recursivelyMerge(table1, table2, tableToUpdate)
				-- table1 will have its changes applied, while table2 is checked against
				for key, value in table1 do
					local matchingValue = table2[key]
					local matchingValueToUpdate = tableToUpdate[key]
					if type(value) == "table" and type(matchingValue) == "table" then
						if type(matchingValueToUpdate) ~= "table" then
							matchingValueToUpdate = {}
							tableToUpdate[key] = matchingValueToUpdate
						end
						recursivelyMerge(value, matchingValue, matchingValueToUpdate)
					elseif not areValuesEqual(value, matchingValue) then
						tableToUpdate[key] = value
						didChange = true
					end
				end
			end
			recursivelyMerge(gamePlayerSettings, previousPlayerSettings, playerSettings)
			if didChange then
				perm:set("PlayerSettings", playerSettings)
				perm:set("PreviousPlayerSettings", gamePlayerSettings)
			end
		end)
		user.beforeSaving:Connect(function()
			-- Set details on last session, playtime, etc
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
	local clockNow = os.clock()
	return {

		-- Data that is saved *and* retrievable by the client
		{"perm", "public", {
			Cash = 0,
			PlayerSettings = deepCopyTable(configSettings.PlayerSettings),
		}},
		
		-- Data that is saved *but not* retrievable by the client
		{"perm", "private", {
			FirstSession = timeNow,
			LastSession = 0,
			TotalPlayTime = 0,
			PreviousPlayerSettings = deepCopyTable(configSettings.PlayerSettings),
			CommandsThisMinute = 0,
			CommandsThisMinuteStartStamp = timeNow,
		}},

		-- Data that is not saved *but* retrievable by the client
		{"temp", "public", {
			PolicyInfo = {},
			Roles = {},
		}},

		-- Data that is not saved *and* not retrievable by the client
		{"temp", "private", {
			LatestSession = timeNow,
			RequestsThisSecond = 0,
			RequestsThisSecondStartClock = clockNow,
			CommandsThisSecond = 0,
			CommandsThisSecondStartClock = clockNow,
		}},

	}
end


return DataStore