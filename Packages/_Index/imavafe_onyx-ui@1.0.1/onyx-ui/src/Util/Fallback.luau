--[=[
	@function Fallback
	@within Util

	@param Value Fusion.UsedAs<any>
	@param Fallback any
	@return any
	
	Defaults the given `Value` to `Fallback` if nil.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)

export type Any = Fusion.UsedAs<any>
export type AnyDictionary = Any | { [any]: Any | AnyDictionary }

local function IsReactive(Value: Any)
	return (typeof(Value) == "table") and (Value.scope ~= nil)
end

local function FallbackUtil(Preferred: Any, Fallback: Any)
	if Preferred == nil then
		return Fallback
	end

	return Preferred
end

local function FallbackDictionary(Preferred: AnyDictionary, Fallback: AnyDictionary)
	if (not IsReactive(Preferred)) and (not IsReactive(Fallback)) then
		if (typeof(Preferred) == "table") and (typeof(Fallback) == "table") then
			for Key, Value in pairs(Fallback) do
				Preferred[Key] = FallbackUtil(Preferred[Key], Value)
			end

			return Preferred
		end
	end

	return FallbackUtil(Preferred, Fallback)
end

return FallbackDictionary
