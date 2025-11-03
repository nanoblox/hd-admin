--!strict
export type ParsedBatch = {
	ParsedStatement
}

export type ParsedStatement = {
	isValid: boolean,
	isConverted: boolean,
	isFromClient: boolean,
	isRestricted: boolean?,
	commands: {[string]: {string}},
	modifiers: {[string]: {string}},
	qualifiers: {[string]: {string}},
	errorMessage: string?,
	callerUserId: number?,
	taskUID: string?,
}

export type ParserRejection =
	"MissingCommandDescription" | -- parsedData was missing a commandDescription, previously
	"UnbalancedCapsulesInCommandDescription" | -- parsedData had unbalanced capsules in commandDescription
	"UnbalancedCapsulesInQualifierDescription" | -- parsedData had unbalanced capsules in qualifierDescription
	"MissingCommands" | -- parsedData was missing commands
	"MalformedCommandDescription" -- parsedData had a malformed command description

export type QualifierRequired = 
	"Always" | -- Parser was able to determine from the commandName that a qualifierDescription is always required
	"Sometimes" | -- Parser was able to determine from the commandName that a qualifierDescription is never required
	"Never" -- Parser was not able to determine from the commandName whether or not a qualifierDescription is required


return {}