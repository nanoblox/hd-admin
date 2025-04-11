-- For details on how HD Admin's framework works, see 'Framework' under Modules.

local MainModule = {}

function MainModule.initialize()
	local Framework = require(script.Value.Modules.Framework)
	return Framework.initialize()
end

return MainModule
