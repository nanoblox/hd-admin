local modules = script:FindFirstAncestor("MainModule").Value.Modules
local configSettings = require(modules.Config.Settings)
local systemSettings = configSettings.SystemSettings

return {
	commandStatementsFromBatchUnFormatted =
		"%s([^%s]+)"
	,
	descriptionsFromCommandStatement = string.format(
		"%s?([^%s]+)",
		systemSettings.DescriptorSeparator,
		systemSettings.DescriptorSeparator
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