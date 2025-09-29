--[=[
		@class TextArea
		
		Like [`TextInput`](/api/TextInput), but dedicated for multi-line use-cases.
]=]

--[=[
		@within TextArea
		@interface TextAreaProps

		. ... TextInputProps -- All TextInput properties are accepted.
]=]

local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local Fusion = require(OnyxUI.Parent.Fusion)

local TextInput = require(OnyxUI.Components.TextInput)
local Components = {
	TextInput = TextInput,
}

export type Props = TextInput.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)

	return Scope:TextInput(Util.CombineProps(Props, {
		AutomaticSize = Enum.AutomaticSize.None,
		TextWrapped = true,
		MultiLine = true,
	}))
end
