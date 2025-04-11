-- LOCAL
--!nocheck
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Serializer = {}
local identifiersToDetails = {}
local validClasses = {}
local dataTypes
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local isWithinMaxSize = require(modules.Utility.VerifyUtil.isWithinMaxSize)
local doTypesMatch = require(modules.Utility.DataUtil.doTypesMatch)
local Compressor = require(modules.Utility.Serializer.Compressor)
dataTypes = {
	--[[
	["number"] = {--!!! Remove ["number"] entirely as its no longer need and infact causes bugs
		identifier = "n",
		--[[
		serialize = function(value)
			return tostring(value)
		end,--]]--[[
		deserialize = function(value)
			return tonumber(value)
		end,
	},--]]
	["string"] = {
		identifier = "s",
		serialize = function(property)
			-- This is for rare cases where strings contain text at the start (such as 'c_')
			-- that conflict with the identifiers. This adds a 's_' for these scenarious to
			-- prevent data mutations 
			local myIdent = dataTypes.string.identifier.."_"
			local fakeIdentifier = property:match("^%l_")
			if fakeIdentifier and fakeIdentifier ~= myIdent then
				return property
			end
			return property, true
		end,
		deserialize = function(value)
			return value
		end,
	},
	["Color3"] = {
		identifier = "c",
		serialize = function(property)
			local r = math.floor(property.r*255+.5)
			local g = math.floor(property.g*255+.5)
			local b = math.floor(property.b*255+.5)
			return ("%02x%02x%02x"):format(r, g, b)
		end,
		deserialize = function(value)
			local r, g, b = value:match("(..)(..)(..)")
			r, g, b = tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
			return Color3.fromRGB(r, g, b)
		end,
        --[[
        serialize = function(property)
			return tostring(property)
		end,
		deserialize = function(value)
			local tValue = value:split(",")
            return Color3.new(unpack(tValue))
        end,--]]
	},
	["EnumItem"] = {
		identifier = "e",
		serialize = function(property)
			return tostring(property):sub(6)
		end,
		deserialize = function(value)
			local tValue = value:split(".")
			return Enum[tValue[1]][tValue[2]]
		end,
	},
	["CFrame"] = {
		identifier = "f",
		serialize = function(property)
			return tostring(property):gsub(" ","")
		end,
		deserialize = function(value)
			local tValue = value:split(",")
			return CFrame.new(unpack(tValue))
		end,
	},
	["Vector3"] = {
		identifier = "v",
		serialize = function(property)
			return tostring(property):gsub(" ","")
		end,
		deserialize = function(value)
			local tValue = value:split(",")
			return Vector3.new(tValue[1], tValue[2], tValue[3])
		end,
	},
	["table"] = {
		isValid = function(tableToCheck)
			for k, v in (tableToCheck) do
				if not Serializer.isValid(k) then
					return false
				elseif not Serializer.isValid(v) then
					return false
				end
			end
			return true
		end,
		serialize = function(property, deepCopy, onlyTables)
			local finalTable = property
			if deepCopy then
				finalTable = {}
			end
			for k, v in (property) do
				local newK = Serializer.serialize(k, deepCopy, onlyTables)
				local newV = Serializer.serialize(v, deepCopy, onlyTables)
				finalTable[k] = nil
				if typeof(newK) == "number" or typeof(newK) == "string" then
					finalTable[newK] = newV
				end
			end
			return finalTable
		end,
		deserialize = function(value, deepCopy)
			for k, v in (value) do
				local origK = Serializer.deserialize(k, deepCopy)
				local origV = Serializer.deserialize(v, deepCopy)
				value[k] = nil
				value[origK] = origV
			end
			return value
		end,
	},
	["Instance"] = {
		serializeOverNetwork = true,
		isValid = function(instance)
			local className = instance.ClassName
			if not validClasses[className] then
				return false
			end
			return true
		end,
		serialize = function(property)
			local className = property.ClassName
			local classModule = validClasses[className]
			if not classModule then
				return nil, true
			end
			local SInstance = require(classModule)
			local processInstance = SInstance.ProcessInstance
			if processInstance then
				property = processInstance(property)
			end
			local newTable = {}
			for k,v in (SInstance.Template) do
				local correspondingValue = property[k]
				if not correspondingValue then
					continue
				elseif not doTypesMatch(v, correspondingValue) then
					continue
				elseif v == correspondingValue then
					continue
				end
				local serializedV = Serializer.serialize(correspondingValue, true)
				newTable[k] = serializedV
			end
			if SInstance.GetChildren then
				local childrenTable = {}
				local allowlist = SInstance.ChildrenAllowlist
				for _, child in (property:GetChildren()) do
					if not allowlist or table.find(allowlist, child.ClassName) then
						local serializedChild = Serializer.serialize(child, true)
						table.insert(childrenTable, serializedChild)
						if not newTable["_icc"] then
							newTable["_icc"] = childrenTable
						end
					end
				end
			end
			local dataLimit = SInstance.DataLimit
			if not isWithinMaxSize(newTable, dataLimit) then
				return nil, true
			end
			newTable["_icn"] = className
			return newTable
		end,
		deserialize = function(value, deepCopy)
			local className = value["_icn"]
			if not className then
				return nil, true
			end
			local classModule = validClasses[className]
			if not classModule then
				return nil, true
			end
			local SInstance = require(classModule)
			local dataLimit = SInstance.DataLimit
			if not isWithinMaxSize(value, dataLimit) then
				return nil, true
			end
			local instance = Instance.new(className)
			local childrenTable = value["_icc"]
			if childrenTable and SInstance.GetChildren then
				local allowlist = SInstance.ChildrenAllowlist
				for _, serializedChild in (childrenTable) do
					if typeof(serializedChild) ~= "table" then
						continue
					end
					local childClassName = serializedChild["_icn"]
					if not allowlist or table.find(allowlist, childClassName) then
						local child = Serializer.deserialize(serializedChild, true)
						if child then
							child.Parent = instance
						end
					end
				end
			end
			for k,v in (SInstance.Template) do
				local corV = value[k]
				local deserCorV = Serializer.deserialize(corV, true)
				local finalValue = v
				if deserCorV and doTypesMatch(deserCorV, v) then
					finalValue = deserCorV
				end
				instance[k] = finalValue
				task.defer(function()
					-- For now we have to do this due to some strange Roblox
					-- behaviour which can set values like Scale to something
					-- completely different
					pcall(function() instance[k] = finalValue end)
				end)
			end
			local processInstance = SInstance.ProcessInstance
			if processInstance then
				instance = processInstance(instance)
			end
			return instance
		end,
	},
}

local function deepCopyOnce(property)
	local newProperty = {}  
	for k, v in (property) do
		newProperty[k] = v
	end
	return newProperty
end



-- SETUP
for identifierName, details in (dataTypes) do
	if details.identifier then
		identifiersToDetails[details.identifier.."_"] = details
	end
end
for _, module in (script.Serializables:GetDescendants()) do
	local className = module.Name
	validClasses[className] = module
end



-- METHODS
function Serializer.compress(serializedData)
	local jsonEncodedData = HttpService:JSONEncode(serializedData)
	local compressedData = Compressor:compress(jsonEncodedData)
	return compressedData
end

function Serializer.decompress(compressedData)
	local jsonEncodedData = Compressor:decompress(compressedData)
	local serializedData = HttpService:JSONDecode(jsonEncodedData)
	return serializedData
end

function Serializer.serialize(property, deepCopy): any?
	if not Serializer.isValid(property) then
		return
	end
	local valueType = typeof(property)
	local details = dataTypes[valueType]
	if details and details.serialize then
		if valueType == "table" and deepCopy then
			property = deepCopyOnce(property)
		end
		local value, ignoreAppending = details.serialize(property, deepCopy)
		if not ignoreAppending then
			if details.identifier then
				value = details.identifier.."_"..value
			end
		end
		return value
	end
	return property
end

function Serializer.deserialize(value: any, deepCopy: boolean?, onlyTables: boolean?): any?
	local valueType = typeof(value)
	if not onlyTables and valueType == "string" then
		local identifier = value:match("^%l_")
		local details = identifiersToDetails[identifier]
		if details and details.deserialize then
			return details.deserialize(value:sub(3))
		end
		return value
	elseif valueType == "table" then
		if deepCopy then
			value = deepCopyOnce(value)
		end
		local dataType = "table"
		if value["_icn"] then
			dataType = "Instance"
		end
		return dataTypes[dataType].deserialize(value, deepCopy, onlyTables)
	end
	return value
end

function Serializer.process(value, deepCopy)
	local serialized = Serializer.serialize(value, deepCopy)
	local compressed = Serializer.compress(serialized)
	return compressed
end

function Serializer.unprocess(value, deepCopy)
	local decompressed = Serializer.decompress(value)
	local deserialized = Serializer.deserialize(decompressed, deepCopy)
	return deserialized
end

function Serializer.processForNetwork(tableValue: {[any]: any}): {[any]: any}
	if RunService:IsServer() then
		local function scanTable(t)
			for k,v in (t) do
				if typeof(v) == "table" then
					scanTable(v)
				elseif Serializer.mustSerializeOverNetwork(v) then
					t[k] = Serializer.serialize(v)
				end
			end
		end
		scanTable(tableValue)
		--tableValue = Serializer.compress(tableValue) -- Compression is not worthwhile over the network, only on much larger items such as the players data when saving
		return tableValue
	end
	--tableValue = Serializer.decompress(tableValue)
	local deserialized = Serializer.deserialize(tableValue, false, true)
	return deserialized
end

function Serializer.mustSerializeOverNetwork(value)
	local valueType = typeof(value)
	local details = dataTypes[valueType]
	local serializeOverNetwork = details and details.serializeOverNetwork
	if serializeOverNetwork then
		return true
	end
	return false
end

function Serializer.isValid(value)
	-- i.e. is it safe for datastores and serialization?
	local valueType = typeof(value)
	local details = dataTypes[valueType]
	local isValid = details and details.isValid
	if isValid and not isValid(value) then
		return false
	end
	if details or valueType == "boolean" or valueType == "number" or valueType == "nil" then
		return true
	end
	return false
end



return Serializer