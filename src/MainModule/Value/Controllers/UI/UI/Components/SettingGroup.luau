local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local SettingsRef = require(HDAdminUI.Static.Settings)
local States = require(HDAdminUI.States)

local Children = Fusion.Children

local Setting = require(script.Parent.Setting)

export type Props = OnyxUI.FrameProps & {
	Title: Fusion.UsedAs<string>?,
	Settings: Fusion.UsedAs<{ SettingsRef.Setting }>,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Setting = Setting,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Title = OnyxUI.Util.Fallback(Props.Title, "Settings")
	local Settings = OnyxUI.Util.Fallback(Props.Settings, {})

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0"]),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Heading {
				Text = Title,
				HeadingSize = 1.5,
			},
			Scope:Divider {},
			Scope:Frame {
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},

				[Children] = {
					Scope:ForValues(Settings, function(Use, Scope, SettingItem: SettingsRef.Setting)
						return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
							return Scope:Setting {
								Label = SettingItem.Name,
								Type = SettingItem.Type,
								Options = SettingItem.Options,
								Default = SettingItem.Default,
								Value = SettingItem.Value,
							}
						end)
					end),
				},
			},
		},
	}))
end
