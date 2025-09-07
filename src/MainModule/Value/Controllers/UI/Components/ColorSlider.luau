local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local States = require(HDAdminUI.States)

local CONFIG = Config:Get()

local Children = Fusion.Children

local PROPERTIES = {
	{
		Name = "Hue",
		Icon = CONFIG.Icons.Color,
	},
	{
		Name = "Brightness",
		Icon = CONFIG.Icons.BrightnessHigh,
	},
}

export type Props = OnyxUI.FrameProps & {
	Color: Fusion.Value<Color3>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Hue = Scope:Value(1)
	local Brightness = Scope:Value(1)
	local Color = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Color, Color3.fromHex("FFFFFF")))

	local function UpdateColor()
		Color:set(Color3.fromHSV(Fusion.peek(Hue), Fusion.peek(Brightness), 1))
	end

	Scope:Observer(Hue):onChange(function()
		UpdateColor()
	end)
	Scope:Observer(Brightness):onChange(function()
		UpdateColor()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},

		[Children] = {
			Scope:ForValues(PROPERTIES, function(Use, Scope, Property: typeof(PROPERTIES[1]))
				return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
					return Scope:Frame {
						Name = Property.Name,
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
							VerticalAlignment = Enum.VerticalAlignment.Bottom,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
						},

						[Children] = {
							Scope:Icon {
								Image = Property.Icon,
								Size = Scope:UDim2Offset(Theme.TextSize["1.25"], Theme.TextSize["1.25"]),
								Aspect = {
									Ratio = 1,
								},
							},
							Scope:Slider {
								Value = ((Property.Name == "Hue") and Hue) or Brightness,
								Color = Color,
							},
						},
					}
				end)
			end),
		},
	}))
end
