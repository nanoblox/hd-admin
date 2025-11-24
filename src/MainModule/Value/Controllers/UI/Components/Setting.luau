local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)

local Children = Fusion.Children

local ColorSlider = require(script.Parent.ColorSlider)
local UserInput = require(script.Parent.UserInput)
local NumberInput = require(script.Parent.NumberInput)
local FilteredTextInput = require(script.Parent.FilteredTextInput)
local Checklist = require(script.Parent.Checklist)
local DurationInput = require(script.Parent.DurationInput)
local MultiTextInput = require(script.Parent.MultiTextInput)

local CONTROLS = {
	Number = {
		Component = NumberInput,
		OutputProp = "Value",
		Inline = false,
		Props = {
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
	Slider = {
		Component = OnyxUI.Components.Slider,
		OutputProp = "Value",
		Inline = false,
		Props = {
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
	String = {
		Component = FilteredTextInput,
		OutputProp = "Text",
		Default = "",
		Inline = false,
		Props = {
			PlaceholderText = "Empty",
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
	UserIds = {
		Component = UserInput,
		OutputProp = "UserIds",
		Default = {},
		Inline = false,
	},
	Boolean = {
		Component = OnyxUI.Components.Switch,
		OutputProp = "Switched",
		Inline = true,
	},
	Color3 = {
		Component = ColorSlider,
		OutputProp = "Color",
		Inline = false,
		Default = Color3.fromHex("FFFFFF"),
		Props = {
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
	TextSwap = {
		Component = OnyxUI.Components.TextSwap,
		OutputProp = "Selection",
		OptionsProp = "Options",
		Default = 1,
		Props = {
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
	Tabs = {
		Component = OnyxUI.Components.Tabs,
		OutputProp = "Tab",
		OptionsProp = "Tabs",
		Default = 1,
		Props = {
			List = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
	Checklist = {
		Component = Checklist,
		OutputProp = "Selection",
		OptionsProp = "Items",
		Default = {},
		Props = {
			List = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},
		},
	},
	Duration = {
		Component = DurationInput,
		OutputProp = "Time",
		Default = 0,
		Props = {
			List = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},
		},
	},
	MultiText = {
		Component = MultiTextInput,
		OutputProp = "Items",
		Default = { "" },
		Props = {
			Flex = {
				Mode = Enum.UIFlexMode.Fill,
			},
		},
	},
}

export type Props = OnyxUI.BaseButtonProps & {
	Label: Fusion.UsedAs<string>,
	Type: Fusion.UsedAs<string>,
	Options: Fusion.UsedAs<{ any }>?,
	Value: Fusion.Value<any>?,
	ControlProps: Fusion.UsedAs<{}>?,
	Inline: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local Label = OnyxUI.Util.Fallback(Props.Label, "Setting")
	local Type = OnyxUI.Util.Fallback(Props.Type, "boolean")
	local Options = OnyxUI.Util.Fallback(Props.Options, nil)
	local Control = Scope:Computed(function(Use)
		return CONTROLS[Use(Type)]
	end)
	local Value = Scope:EnsureValue(Props.Value)
	local ControlProps = OnyxUI.Util.Fallback(Props.ControlProps, {})
	local Inline = OnyxUI.Util.Fallback(
		Props.Inline,
		Scope:Computed(function(Use)
			local ControlValue = Use(Control) or {}

			return ControlValue.Inline or false
		end)
	)

	local function SetSafeDefault()
		local ControlValue = Fusion.peek(Control)
		local ValueValue = Fusion.peek(Value)

		if (ValueValue == nil) and (ControlValue.Default ~= nil) then
			Value:set(ControlValue.Default)
		end
	end

	SetSafeDefault()

	return Scope:BaseButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			FillDirection = Scope:Computed(function(Use)
				return (Use(Inline) and Enum.FillDirection.Horizontal) or Enum.FillDirection.Vertical
			end),
			HorizontalFlex = Scope:Computed(function(Use)
				return (Use(Inline) and Enum.UIFlexAlignment.SpaceBetween) or Enum.UIFlexAlignment.Fill
			end),
		},

		OnActivate = function()
			if Fusion.peek(Type) == "Boolean" then
				Value:set(not Fusion.peek(Value))
			end
		end,

		[Children] = {
			Scope:Computed(function(Use)
				local LabelValue = Use(Label)

				if string.len(LabelValue) >= 1 then
					return Scope:Text {
						Text = Label,
						TextSize = Scope:Computed(function(Use)
							if Use(Inline) then
								return Use(Theme.TextSize["1"])
							else
								return Use(Theme.TextSize["1.25"])
							end
						end),
						AutomaticSize = Scope:Computed(function(Use)
							return (Use(Inline) and Enum.AutomaticSize.XY) or Enum.AutomaticSize.Y
						end),
					}
				end
			end),
			Scope:Computed(function(Use)
				local ControlValue = Use(Control)

				if ControlValue ~= nil then
					return ControlValue.Component(
						Scope,
						OnyxUI.Util.CombineProps({
							[ControlValue.OutputProp] = Value,
							[ControlValue.OptionsProp or "Options"] = Options,
							AutomaticSize = Enum.AutomaticSize.Y,
						}, OnyxUI.Util.CombineProps(ControlValue.Props or {}, Use(ControlProps)))
					)
				end
			end),
		},
	}))
end
