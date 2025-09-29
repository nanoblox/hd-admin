local function deprecateWarnOnce(method)
	return function(oldMethod: string, newMethod: string, removalInVersion: string?): typeof(method)
		local didWarn = false

		return function(...)
			if not didWarn then
				local removalString = removalInVersion and ` and will be removed in {removalInVersion}` or ""

				didWarn = true
				warn(`{oldMethod} is deprecated{removalString}. Please use {newMethod} instead.`)
			end

			return method(...)
		end
	end
end

return deprecateWarnOnce
