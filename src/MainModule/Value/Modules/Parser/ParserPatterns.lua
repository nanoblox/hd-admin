local modules = script:FindFirstAncestor("MainModule").Value.Modules
local configSettings = require(modules.Config.Settings)
local systemSettings = configSettings.SystemSettings
local DESCRIPTOR_SEPARATOR = " "

return {
	commandStatementsFromBatchUnFormatted =
		"%s([^%s]+)"
	,
	descriptionsFromCommandStatement = string.format(
		"%s?([^%s]+)",
		DESCRIPTOR_SEPARATOR,
		DESCRIPTOR_SEPARATOR
	),
	argumentsFromCollection = string.format(
		"([^%s]+)%s?",
		systemSettings.Collective,
		systemSettings.Collective
	),
	capsuleFromKeyword = string.format(
		"%%(%s%%)", --Capsule
		string.format("(%s)", ".-")
	),
}