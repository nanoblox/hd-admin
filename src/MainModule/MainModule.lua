-- For details on how HD Admin's framework works, see 'Framework' under Modules.

local MainModule = {}

function MainModule.initialize(loader)
	local Framework = require(script.Value.Modules.Framework)
	return Framework.initialize(loader)
end

return MainModule
