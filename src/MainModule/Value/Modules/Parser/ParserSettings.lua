-- These are configurable, but HD Admin has only been extensively tested under these
-- default settings, so it's highly recommended to keep these as-is to avoid issues.
local ENDLESS_SEPARATOR = "|"
return {
	Collective = ",", -- The character used to split up items (e.g. ,jump player1,player2,player3)
	SpaceSeparator = " ", -- The character inbetween command arguments (e.g. setting it to '/' would change ';jump me' to ';jump/me')
	EndlessArgSeparator = ENDLESS_SEPARATOR, -- The character used to separate two endless arguments (e.g. ';poll all What is your favourite color? || Red | Dark Blue | Green')
	EndlessArgPattern = ` {ENDLESS_SEPARATOR}{ENDLESS_SEPARATOR} `,
	EndlessFieldsPattern = ` {ENDLESS_SEPARATOR} `
}