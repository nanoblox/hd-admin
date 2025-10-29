local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Config = require(UI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, _Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, {})

	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:BaseButton {
		Name = script.Name,
		Size = UDim2.fromScale(1, 1),
		Visible = States.Guide.Open,
		BackgroundTransparency = 0.3,
		BackgroundColor3 = OnyxUI.Util.Colors.Black,
		List = {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		},

		OnActivate = function()
			States.Guide.Open:set(false)
		end,

		[Children] = {
			Scope:AutoScaler {
				BaseResolution = Vector2.new(700, 500),
				MaxScale = 1,
				MinScale = 0,

				[Children] = {
					Scope:BaseButton {
						OnActivate = function()
							local ImageCallbackValue = Fusion.peek(States.Guide.ImageCallback)

							if ImageCallbackValue ~= nil then
								ImageCallbackValue()
							end
						end,

						[Children] = {
							Scope:Image {
								Image = States.Guide.Image,
								Size = Scope:UDim2Offset(Theme.Sizing["32"], 1000000),
								AutomaticSize = Enum.AutomaticSize.None,
								BackgroundTransparency = 0,
								Aspect = {
									Ratio = 16 / 9,
									DominantAxis = Enum.DominantAxis.Width,
									Type = Enum.AspectType.FitWithinMaxSize,
								},
								Corner = {
									Radius = Scope:UDim(0, Theme.CornerRadius["2"]),
								},
								Padding = {
									All = Scope:UDim(0, Theme.Padding["0.5"]),
								},
								Stroke = {},

								[Children] = {
									Scope:IconButton {
										Image = CONFIG.Icons.Close,
										AnchorPoint = Vector2.new(1, 0),
										Position = UDim2.fromScale(1, 0),
										SizeVariant = "ExtraLarge",
										BackgroundTransparency = 0.5,
										Stroke = {
											Enabled = false,
										},

										OnActivate = function()
											States.Guide.Open:set(false)
										end,
									},
								},
							},
						},
					},
				},
			},
		},
	}
end
