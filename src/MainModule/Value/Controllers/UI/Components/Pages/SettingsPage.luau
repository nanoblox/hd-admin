local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Settings = require(UI.Static.Settings)
local States = require(UI.States)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Children = Fusion.Children

local SettingGroup = require(script.Parent.Parent.SettingGroup)
local CustomButton = require(script.Parent.Parent.CustomButton)

local function RestoreDefaults()
	for _, Category in ipairs(Settings) do
		for _, Setting in ipairs(Category.Settings) do
			Setting.Value:set(Setting.Default)
		end
	end
end

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		SettingGroup = SettingGroup,
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.fromOffset(0, 0),
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = Scope:UDim(0, Theme.Spacing["2"]),
		},

		[Children] = {
			Scope:ForValues(Settings, function(Use, Scope, Category: Settings.Category)
				return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
					return PanelsStateMod.Panel:is(Panel):during(function()
						return Scope:SettingGroup {
							Title = Category.Name,
							Settings = Category.Settings,
						}
					end)
				end)
			end),
			Scope:Button {
				Content = { "Restore Defaults" },
				ContentSize = Theme.TextSize["1"],
				SizeVariant = "ExtraLarge",

				OnActivate = function()
					RestoreDefaults()
				end,
			},
		},
	}))
end
