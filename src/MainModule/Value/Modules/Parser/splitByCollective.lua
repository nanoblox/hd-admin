--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
return function(stringToParse: string): {string}
	if typeof(stringToParse) ~= "string" then
		return {}
	end
	local ParserSettings = require(modules.Parser.ParserSettings)
	local collective = ParserSettings.Collective
	local stringToParse = string.split(stringToParse, collective)
	return stringToParse
end