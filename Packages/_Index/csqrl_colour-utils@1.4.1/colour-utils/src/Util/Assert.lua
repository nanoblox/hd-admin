local Assert = {}

local fmt = string.format

type Array = { [number]: any }

Assert.TYPE = {
	INVALID_TYPE = "%s(...): The `%s` argument must be a %s, but you passed %q (%s)",
	INVALID_ARRAY = "%s(...): The `%s` argument must be an array of %s, but you passed %q (%s) at index #%d",
	INVALID_EVAL_ARG = "%s(...): The `%s` argument must %s, but you passed %q (%s)",
}

function Assert.typeOf<T>(methodName: string, argName: string, class: string, value: T?): T
	local errorText = fmt(Assert.TYPE.INVALID_TYPE, methodName, argName, class, tostring(value), typeof(value))

	if typeof(value) ~= class then
		error(errorText, 3)
	end

	return value
end

function Assert.evalArg<T>(methodName: string, argName: string, message: string, eval: boolean?, value: T?): T
	local errorText = fmt(Assert.TYPE.INVALID_EVAL_ARG, methodName, argName, message, tostring(value), typeof(value))

	if eval ~= true then
		error(errorText, 3)
	end

	return value
end

function Assert.arrayOf(methodName: string, argName: string, class: string, array: Array): nil
	Assert.typeOf("Assert.arrayOf", "array", "table", array)

	for index, value in ipairs(array) do
		if typeof(value) ~= class then
			local errorText =
				fmt(Assert.TYPE.INVALID_ARRAY, methodName, argName, class, tostring(value), typeof(value), index)
			error(errorText, 3)
		end
	end

	return nil
end

function Assert.prepTypeOf(methodName: string)
	return function(argName: string, class: string, value: any?)
		return Assert.typeOf(methodName, argName, class, value)
	end
end

function Assert.prepEvalArg(methodName: string)
	return function(argName: string, message: string, eval: boolean?, value: any?)
		return Assert.evalArg(methodName, argName, message, eval, value)
	end
end

function Assert.prepArrayOf(methodName: string)
	return function(argName: string, class: string, array: Array)
		return Assert.arrayOf(methodName, argName, class, array)
	end
end

return Assert
