local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HDAdminUI = script.Parent.Parent
local ColorUtils = require(ReplicatedStorage.HDAdminUI.Packages.ColorUtils)
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Sift)
local States = require(HDAdminUI.States)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)
local Signals = require(HDAdminUI.Signals)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = OnyxUI.ButtonProps & {
	Id: Fusion.UsedAs<string>?,
	QuickRun: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Id = OnyxUI.Util.Fallback(Props.Id, "Command")
	local QuickRun = OnyxUI.Util.Fallback(Props.QuickRun, false)

	local Running = Scope:Value(false)
	local Runs = Scope:Value(0)

	local Command = Scope:Computed(function(Use)
		local IdValue = Use(Id)

		return CONFIG.Commands[IdValue]
	end)
	local SafeCommand = Scope:Computed(function(Use)
		local CommandValue = Use(Command)

		return Sift.Dictionary.merge({
			Prompt = "command",
			Arguments = {},
		}, CommandValue or {})
	end)
	local ArgumentsAreOptional = Scope:Computed(function(Use)
		local SafeCommandValue = Use(SafeCommand)

		return Sift.Array.every(SafeCommandValue.Arguments, function(Argument)
			return Argument.Optional == true
		end)
	end)
	local QuickRunEnabled = Scope:Computed(function(Use)
		local SafeCommandValue = Use(SafeCommand)
		local QuickRunValue = Use(QuickRun)
		local ArgumentsAreOptionalValue = Use(ArgumentsAreOptional)

		return ArgumentsAreOptionalValue and ((#SafeCommandValue.Arguments == 0) or QuickRunValue)
	end)
	local Color = Scope:Computed(function(Use)
		if Use(Running) then
			return Use(Theme.Colors.Primary.Main)
		else
			return Use(Theme.Colors.Neutral.Main)
		end
	end)
	local ContentColor = Scope:Computed(function(Use)
		return ColorUtils.Emphasize(Use(Color), 1)
	end)

	return Scope:Button(OnyxUI.Util.CombineProps(Props, {
		Color = Scope:Spring(Color, Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
		List = {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
		Padding = {
			Top = Scope:UDim(0, Theme.Padding["0.5"]),
			Left = Scope:UDim(0, Theme.Padding["0.75"]),
			Right = Scope:UDim(0, Theme.Padding["0.75"]),
			Bottom = Scope:UDim(0, Theme.Padding["0.5"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},

		OnActivate = function()
			local IdValue = Fusion.peek(Id)
			local QuickRunEnabledValue = Fusion.peek(QuickRunEnabled)

			if IdValue ~= nil then
				if QuickRunEnabledValue then
					task.spawn(function()
						Runs:set(Fusion.peek(Runs) + 1)
						Running:set(true)
						task.wait(25 / Fusion.peek(Theme.SpringSpeed["1"]))
						Running:set(false)
					end)

					Signals.CommandRan:Fire(IdValue, {})
				else
					States.Menu.Pages.Execute.CommandId:set(IdValue)
					NavigationStateMod:To("Execute")
				end
			end
		end,

		[Children] = {
			Scope:Frame {
				Name = "RunSpinner",

				[Children] = {
					Scope:Icon {
						Image = CONFIG.Icons.RunCommand,
						Rotation = Scope:Spring(
							Scope:Computed(function(Use)
								return Use(Runs) * 360
							end),
							Theme.SpringSpeed["0.5"],
							Theme.SpringDampening["1.5"]
						),
						ImageColor3 = Scope:Spring(ContentColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
					},
				},
			},
			Scope:IconText {
				Name = "Prompt",
				Content = Scope:Computed(function(Use)
					local SafeCommandValue = Use(SafeCommand)
					local QuickRunEnabledValue = Use(QuickRunEnabled)

					return {
						`{Use(States.Settings.Prefix)}{SafeCommandValue.Prompt}`,
						QuickRunEnabledValue and CONFIG.Icons.ZapFill or "",
					}
				end),
				ContentColor = Scope:Spring(ContentColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
				ContentWrapped = false,
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},
				List = {
					Padding = Scope:UDim(0, Theme.Padding["0.25"]),
				},
			},
			Scope:IconButton {
				Name = "StopExecution",
				Image = CONFIG.Icons.StopFill,
				Active = Running,
				Color = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Running) then
							return Use(Theme.Colors.Primary.Main)
						else
							return Use(Theme.Colors.Neutral.Main)
						end
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1.5"]
				),
				ContentColor = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Running) then
							return Use(Theme.Colors.Primary.Contrast)
						else
							return Use(Theme.Colors.Neutral.Light)
						end
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1.5"]
				),
				SizeVariant = "Small",

				OnActivate = function()
					local IdValue = Fusion.peek(Id)
					local CommandValue = Fusion.peek(Command)

					if CommandValue ~= nil then
						Signals.CommandStopped:Fire(IdValue)
					end
				end,
			},
		},
	}))
end
