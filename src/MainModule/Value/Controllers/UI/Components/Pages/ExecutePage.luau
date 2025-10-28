local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Config = require(UI.Config)
local Sift = require(Packages.Sift)
local Callbacks = require(UI.Callbacks)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local SettingGroup = require(script.Parent.Parent.SettingGroup)
local CustomButton = require(script.Parent.Parent.CustomButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		SettingGroup = SettingGroup,
		CustomButton = CustomButton,
	})

	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local CommandId = Panel.PagesData.Execute.CommandId
	local TextPromptToShow = Scope:Value("")

	local Command = Scope:Computed(function(Use)
		local CommandIdValue = Use(CommandId)

		return Sift.Dictionary.merge({
			Name = "Command",
			Aliases = {},
			Arguments = {},
			Role = "Guest",
		}, CONFIG.Commands[CommandIdValue])
	end)
	local SafeArguments = Scope:Computed(function(Use)
		return Use(Command).Arguments
	end)
	local ArgumentSettings = Scope:ForValues(SafeArguments, function(Use, Scope, Argument)
		return {
			Name = Argument.Name,
			Type = Argument.Type,
			Options = Argument.Options,
			Value = Scope:Value((Argument.Type == "string" and "") or nil),
		}
	end)
	local ArgumentSettingValues = Scope:ForValues(ArgumentSettings, function(Use, Scope, ArgumentSetting)
		return Fusion.peek(ArgumentSetting.Value)
	end)
	local TextPrompt = Scope:Computed(function(Use)
		return `{Use(States.Settings.Prefix)}{Use(Command).Name} <arg1> <arg2>`
	end)

	Scope:Observer(function()
		TextPromptToShow:set(Fusion.peek(TextPrompt))
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Wraps = true,
		},

		[Children] = {
			Scope:Scroller {
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},

				[Children] = {
					Scope:SettingGroup {
						Title = Scope:Computed(function(Use)
							local SafeCommandValue = Use(Command)
							local PrefixValue = Use(States.Settings.Prefix)

							return `{PrefixValue}{SafeCommandValue.Name}`
						end),
						Settings = ArgumentSettings,
					},
				},
			},
			Scope:Frame {
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:TextInput {
						Text = TextPrompt,
						TextEditable = false,
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.Colors.Neutral.Main,
					},
					Scope:Button {
						Content = { "Run" },
						Color = Theme.Colors.Primary.Main,
						SizeVariant = "ExtraLarge",
						ContentSize = Theme.TextSize["1"],

						OnActivate = function()
							Callbacks.RunCommand(
								Fusion.peek(Panel.PagesData.Execute.CommandId),
								Fusion.peek(ArgumentSettingValues)
							)
						end,
					},
				},
			},
		},
	}))
end
