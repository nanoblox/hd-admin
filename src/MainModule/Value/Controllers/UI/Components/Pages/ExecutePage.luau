local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Sift)
local Signals = require(HDAdminUI.Signals)

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

	local Command = Scope:Computed(function(Use)
		local IdValue = Use(States.Menu.Pages.Execute.CommandId)

		return CONFIG.Commands[IdValue]
	end)
	local SafeCommand = Scope:Computed(function(Use)
		local CommandValue = Use(Command)

		return Sift.Dictionary.merge({
			Prompt = "command",
			Arguments = {},
			Callback = function() end,
		}, CommandValue or {})
	end)
	local SafeArguments = Scope:Computed(function(Use)
		return Use(SafeCommand).Arguments
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

	local TextPrompt = Scope:Value("")

	local TextPromptComputed = Scope:Computed(function(Use)
		return `{Use(States.Settings.Prefix)}{Use(SafeCommand).Prompt} <arg1> <arg2>`
	end)
	Scope:Observer(TextPromptComputed):onChange(function()
		TextPrompt:set(Fusion.peek(TextPromptComputed))
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
							local SafeCommandValue = Use(SafeCommand)
							local PrefixValue = Use(States.Settings.Prefix)

							return `{PrefixValue}{SafeCommandValue.Prompt}`
						end),
						Settings = ArgumentSettings,
					},
				},
			},
			Scope:Frame {
				Name = "Execute",
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:TextInput {
						Name = "PromptBox",
						Text = TextPrompt,
						TextEditable = false,
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.Colors.Neutral.Main,
					},
					Scope:Button {
						Name = "ExecuteButton",
						Content = { "Execute" },
						Color = Theme.Colors.Primary.Main,
						SizeVariant = "ExtraLarge",
						ContentSize = Theme.TextSize["1"],

						OnActivate = function()
							Signals.CommandRan:Fire(
								Fusion.peek(States.Menu.Pages.Execute.CommandId),
								Fusion.peek(ArgumentSettingValues)
							)
						end,
					},
				},
			},
		},
	}))
end
