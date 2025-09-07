local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)

local Children = Fusion.Children

export type Props = OnyxUI.BaseProps & {
	Number: Fusion.Value<number>?,
	Minimum: Fusion.UsedAs<number>?,
	Round: Fusion.UsedAs<boolean>?,
	OnFocusEnd: Fusion.UsedAs<((number) -> ())>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Number = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Number, 0))
	local Round = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Round, false))
	local Minimum = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Minimum, -math.huge))
	local OnFocusEnd = OnyxUI.Util.Fallback(Props.OnFocusEnd, function() end)

	local TextNumber = Scope:Value(tonumber(Fusion.peek(Number)))

	Scope:Observer(Number):onChange(function()
		TextNumber:set(`{Fusion.peek(Number)}`)
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},

		[Children] = {
			Scope:TextInput {
				Text = TextNumber,
				TextColor3 = Theme.Colors.NeutralContent.Main,
				FontFace = Scope:Font(Theme.Font.Monospace, Theme.FontWeight.Bold),
				TextProcessor = function(Text: string)
					return `{string.gsub(string.gsub(Text, "[^%d%.%-]", ""), "^(%-?%d*%.?%d*).*", "%1")}`
				end,

				OnFocusEnd = function()
					local OnFocusEndValue = Fusion.peek(OnFocusEnd)
					local MinimumValue = Fusion.peek(Minimum)
					local RoundValue = Fusion.peek(Round)
					local NewNumber = math.clamp(tonumber(Fusion.peek(TextNumber)) or 0, MinimumValue or 0, math.huge)

					if RoundValue == true then
						NewNumber = math.floor(NewNumber)
					end

					Number:set(NewNumber)
					TextNumber:set(`{NewNumber or 0}`)

					OnFocusEndValue(NewNumber or 0)
				end,
				OnFocus = function()
					if Fusion.peek(TextNumber) == "0" then
						TextNumber:set("")
					end
				end,
			},
		},
	}))
end
