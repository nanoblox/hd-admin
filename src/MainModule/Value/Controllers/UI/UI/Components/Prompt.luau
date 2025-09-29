local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local States = require(HDAdminUI.States)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = CustomButton.Props & {
	Body: Fusion.UsedAs<{ string }>?,
	Title: Fusion.UsedAs<{ string }>?,
	Callback: Fusion.UsedAs<() -> ()>?,
	Actions: Fusion.UsedAs<{
		{
			Content: { string },
			Callback: () -> (),
		}
	}>?,
	Lifetime: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Body = OnyxUI.Util.Fallback(Props.Body, {})
	local Title = OnyxUI.Util.Fallback(Props.Title, {})
	local Callback = OnyxUI.Util.Fallback(Props.Callback, function() end)
	local Actions = OnyxUI.Util.Fallback(
		Props.Actions,
		Scope:Computed(function(Use)
			return {}
		end)
	)
	local Lifetime = OnyxUI.Util.Fallback(Props.Lifetime, -1)

	local Padding = Scope:UDim(0, Theme.Padding["1"])

	local SpawnTime = DateTime.now().UnixTimestampMillis

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Color = Theme.Colors.Base.Main,
		AutomaticSize = Enum.AutomaticSize.Y,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		},
		Padding = {
			Top = Padding,
			Left = Padding,
			Right = Padding,
			Bottom = Padding,
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},

		OnActivate = function()
			Fusion.peek(Callback)()
		end,

		[Children] = {
			Scope:Frame {
				Name = "Info",
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},

				[Children] = {
					Scope:Frame {
						Name = "TitleBar",
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
						},

						[Children] = {
							Scope:IconText {
								Name = "Title",
								Content = Title,
								ContentFontFace = Scope:Computed(function(Use)
									return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
								end),
								ContentWrapped = false,
								AutomaticSize = Enum.AutomaticSize.Y,
								ClipsDescendants = true,
								Flex = {
									Mode = Enum.UIFlexMode.Fill,
								},
							},
							Scope:Icon {
								Image = CONFIG.Icons.LogoGlyphOutline,
								ImageColor3 = Theme.Colors.NeutralContent.Dark,
							},
						},
					},
					Scope:IconText {
						Name = "Body",
						Content = Body,
						ContentColor = Theme.Colors.NeutralContent.Main,
						AutomaticSize = Enum.AutomaticSize.Y,
						List = {
							Wraps = true,
						},
					},
				},
			},
			Scope:Computed(function(Use)
				if #Use(Actions) >= 1 then
					return Scope:Frame {
						Name = "Actions",
						List = {
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
						},

						[Children] = {
							Scope:ForValues(Actions, function(Use, Scope, Action)
								return Scope:Button {
									Content = Action.Content,
									OnActivate = Action.Callback,
								}
							end),
						},
					}
				end
			end),
			Scope:Computed(function(Use)
				if Use(Lifetime) >= 0 then
					return Scope:ProgressBar {
						Name = "ExpiryBar",
						Progress = Scope:Computed(function(Use)
							local UnixTimeValue = Use(States.UnixTime)
							local LifetimeValue = Use(Lifetime) * 1000

							return math.clamp(
								(((SpawnTime + LifetimeValue) - UnixTimeValue) / LifetimeValue) or 0,
								0,
								1
							)
						end),
						Color = Theme.Colors.BaseContent.Main,
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(0, Use(Theme.TextSize["1"]) / 3)
						end),
					}
				end
			end),
		},
	}))
end
