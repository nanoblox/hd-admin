local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local ColorUtils = require(Packages.ColorUtils)
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Config = require(UI.Config)
local Sift = require(Packages.Sift)
local States = require(UI.States)
local Callbacks = require(UI.Callbacks)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local Future = require(Packages.Future)

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
	local Panel = PanelsStateMod.Panel:now()

	local Id = OnyxUI.Util.Fallback(Props.Id, "Command")

	local Running = Scope:Value(false)
	local Runs = Scope:Value(0)

	local Command = Scope:Computed(function(Use)
		local IdValue = Use(Id)

		return CONFIG.Commands[IdValue]
	end)
	local SafeCommand = Scope:Computed(function(Use)
		local CommandValue = Use(Command)

		return Sift.Dictionary.merge({
			Name = "command",
			Arguments = {},
		}, CommandValue or {})
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
			Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
		},
		Padding = {
			Top = Scope:UDim(0, Theme.Padding["0"]),
			Left = Scope:UDim(0, Theme.Padding["0"]),
			Right = Scope:UDim(0, Theme.Padding["0"]),
			Bottom = Scope:UDim(0, Theme.Padding["0"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},

		OnActivate = function()
			local IdValue = Fusion.peek(Id)

			if IdValue ~= nil then
				Panel.PagesData.Execute.CommandId:set(IdValue)
				PanelsStateMod.ToPage(Panel, "Execute")
			end
		end,

		[Children] = {
			Scope:IconButton {
				Style = "Ghost",
				List = {
					Enabled = false,
				},
				Padding = {
					Top = Scope:UDim(0, Theme.Padding["0.75"]),
					Bottom = Scope:UDim(0, Theme.Padding["0.75"]),
					Left = Scope:UDim(0, Theme.Padding["0.75"]),
					Right = Scope:UDim(0, Theme.Padding["0.75"]),
				},

				OnActivate = function()
					local IdValue = Fusion.peek(Id)

					if IdValue ~= nil then
						Future.Try(function()
							Callbacks.RunCommand(IdValue, {})
						end):After(function(Success, Result)
							if not Success then
								warn(Result)
							end
						end)
					end

					task.spawn(function()
						Runs:set(Fusion.peek(Runs) + 1)
						Running:set(true)
						task.wait(25 / Fusion.peek(Theme.SpringSpeed["1"]))
						Running:set(false)
					end)
				end,

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
			Scope:Text {
				Text = Scope:Computed(function(Use)
					local SafeCommandValue = Use(SafeCommand)

					return `{Use(States.Settings.Prefix)}{SafeCommandValue.Name}`
				end),
				TextColor = Scope:Spring(ContentColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
				TextWrapped = false,
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},
			},
			Scope:IconButton {
				Image = CONFIG.Icons.StopFill,
				Active = Running,
				Visible = Running,
				Style = "Ghost",
				Color = Theme.Colors.Primary.Contrast,
				Padding = {
					Top = Scope:UDim(0, Theme.Padding["0.75"]),
					Bottom = Scope:UDim(0, Theme.Padding["0.75"]),
					Left = Scope:UDim(0, Theme.Padding["0.75"]),
					Right = Scope:UDim(0, Theme.Padding["0.75"]),
				},

				OnActivate = function()
					local IdValue = Fusion.peek(Id)
					local CommandValue = Fusion.peek(Command)

					if CommandValue ~= nil then
						Callbacks.StopCommandTasks(IdValue)
					end
				end,
			},
		},
	}))
end
