local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Config = require(UI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

export type Props = OnyxUI.FrameProps & {
	Text: Fusion.Value<string>?,
	OnFocusEnd: Fusion.UsedAs<() -> ()>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Text = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Text, ""))
	local OnFocusEnd = OnyxUI.Util.Fallback(Props.OnFocusEnd, function() end)

	local FilterPassed = Scope:Value(nil)

	local FilterAttributesSource = {
		["true"] = {
			Color = Theme.Colors.Success.Main,
			Icon = CONFIG.Icons.CheckMarkFill,
		},
		["false"] = {
			Color = Theme.Colors.Error.Main,
			Icon = CONFIG.Icons.WarningFill,
		},
		["nil"] = {
			Color = Theme.Colors.NeutralContent.Main,
			Icon = CONFIG.Icons.TextFill,
		},
	}

	local FilterAttributes = Scope:Computed(function(Use)
		local FilterPassedValue = Use(FilterPassed)

		return FilterAttributesSource[tostring(FilterPassedValue)]
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},

		[Children] = {
			Scope:TextInput {
				Text = Text,
				TextColor3 = Theme.Colors.NeutralContent.Main,
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				OnFocusEnd = OnFocusEnd,
			},
			Scope:IconText {
				Name = "FilterStatus",
				Content = Scope:Computed(function(Use)
					local FilterAttributesValue = Use(FilterAttributes)

					return { FilterAttributesValue.Icon }
				end),
				ContentColor = Scope:Computed(function(Use)
					local FilterAttributesValue = Use(FilterAttributes)

					return Use(FilterAttributesValue.Color)
				end),
				ContentSize = Theme.TextSize["1.25"],
			},
		},
	}))
end
