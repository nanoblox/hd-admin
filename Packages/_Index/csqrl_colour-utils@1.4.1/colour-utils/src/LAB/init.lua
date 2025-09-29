local CONST = require(script.Constants)

export type LAB = CONST.LAB

--[=[
	@class LAB
]=]
return {
	fromLAB = require(script.FromLAB),
	toLAB = require(script.ToLAB),
	Lerp = require(script.Lerp),
}
