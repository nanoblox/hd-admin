local CONST = require(script.Constants)

export type LCH = CONST.LCH

--[=[
  @class LCH
]=]
return {
	toLCH = require(script.ToLCH),
	fromLCH = require(script.FromLCH),
}
