local modules = script:FindFirstAncestor("MainModule").Value.Modules
local configSettings = require(modules.Parent.Services.Config.Settings)
local systemSettings = configSettings.SystemSettings
local ParserSettings = require(modules.Parser.ParserSettings)

return {
	commandStatementsFromBatchUnFormatted =
		"%s([^%s]+)"
	,
	descriptionsFromCommandStatement = string.format(
		"%s?([^%s]+)",
		ParserSettings.SpaceSeparator,
		ParserSettings.SpaceSeparator
	),
	argumentsFromCollection = string.format(
		"([^%s]+)%s?",
		ParserSettings.Collective,
		ParserSettings.Collective
	),
	capsuleFromKeyword = string.format(
		"%%(%s%%)", --Capsule
		string.format("(%s)", ".-")
	),
}