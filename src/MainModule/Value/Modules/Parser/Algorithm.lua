--!nonstrict

--[[

Analyzes the given command name to determine whether or not it's appearance in a
commandstatement mandates that commandstatement to require a qualifierdescription
to be considered valid.

It is not always possible to determine qualifierdescription requirement solely from
the command name or the data associated with it but rather has to be confirmed further
from the information of the commandstatement it appears in.

1) If every argument for the command has playerArg ~= true then returns QualifierRequired.Never

2) If even one argument for the command has playerArg == true and hidden ~= true returns
	QualifierRequired.Always

3) If condition (1) and condition (2) are not satisfied, meaning every argument for
	the command has playerArg == true and hidden == true returns QualifierRequired.Sometimes

]]

local Algorithm = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local parserModules = modules.Parser
local Modifiers = require(parserModules.Modifiers)
local Qualifiers = require(parserModules.Qualifiers)
local ParserPatterns = require(parserModules.ParserPatterns)
local Commands = require(services.Commands)


function Algorithm.getCommandStatementsFromBatch(batch, prefixUsed)
	
	local ParserUtility =  require(modules.Parser.ParserUtility)
	local formattedPattern = string.format(
		ParserPatterns.commandStatementsFromBatchUnFormatted,
		prefixUsed,
		prefixUsed
	)
	local matches = ParserUtility.getMatches(batch, formattedPattern)
	return matches
end

function Algorithm.getDescriptionsFromCommandStatement(commandStatement)
	local ParserUtility =  require(modules.Parser.ParserUtility)
	local descriptions = ParserUtility.getMatches(
		commandStatement,
		ParserPatterns.descriptionsFromCommandStatement
	)
	
	local extraArgumentDescription = {}
	if #descriptions >= 3 then
		for counter = 3, #descriptions do
			table.insert(extraArgumentDescription, descriptions[counter])
		end
	end

	return {
		descriptions[1] or "",
		descriptions[2] or "",
		extraArgumentDescription,
	}
end

function Algorithm.parseCommandDescription(commandDescription)
	local ParserUtility =  require(modules.Parser.ParserUtility)
	
	local commandCapsuleCaptures, commandDescriptionResidue = ParserUtility.getCapsuleCaptures(
		commandDescription,
		Commands.getSortedNameAndAliasLengthArray()
	)
	local commandPlainCaptures, commandDescriptionResidue = ParserUtility.getPlainCaptures(
		commandDescriptionResidue,
		Commands.getSortedNameAndAliasLengthArray()
	)
	local commandCaptures = ParserUtility.combineCaptures(commandCapsuleCaptures, commandPlainCaptures)

	local modifierCapsuleCaptures, commandDescriptionResidue = ParserUtility.getCapsuleCaptures(
		commandDescriptionResidue,
		Modifiers.getSortedNameAndAliasLengthArray()
	)
	local modifierPlainCaptures, commandDescriptionResidue = ParserUtility.getPlainCaptures(
		commandDescriptionResidue,
		Modifiers.getSortedNameAndAliasLengthArray()

	)
	local modifierCaptures = ParserUtility.combineCaptures(modifierCapsuleCaptures, modifierPlainCaptures)

	return {
		commandCaptures,
		modifierCaptures,
		commandDescriptionResidue,
	}
end

function Algorithm.parseQualifierDescription(qualifierDescription)
	local ParserUtility =  require(modules.Parser.ParserUtility)

	local qualifierCaptures, qualifierDescriptionResidue = ParserUtility.getCapsuleCaptures(
		qualifierDescription,
		Qualifiers.getSortedNameAndAliasLengthArray()
	)

	local qualifiers = ParserUtility.getMatches(
		qualifierDescriptionResidue,
		ParserPatterns.argumentsFromCollection
	)
	local unrecognizedQualifiers = {}

	local qualifierDictionary = Qualifiers.getLowercaseDictionary()
	for _, match in pairs(qualifiers) do
		if match ~= "" then
			if not qualifierDictionary[match:lower()] then
				table.insert(unrecognizedQualifiers, match)
			end
			table.insert(qualifierCaptures, { [match] = {} })
		end
	end

	return {
		qualifierCaptures,
		unrecognizedQualifiers,
	}
end

function Algorithm.parseExtraArgumentDescription(extraArgumentDescription)
end


return Algorithm