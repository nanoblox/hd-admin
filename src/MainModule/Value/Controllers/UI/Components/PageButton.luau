local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Pages = require(UI.Static.Pages)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = CustomButton.Props & {
	Id: Fusion.UsedAs<string>,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local Id = OnyxUI.Util.Fallback(Props.Id, nil)
	local Padding = OnyxUI.Util.Fallback(Props.Padding, Scope:UDim(0, Theme.Padding["1"]))

	local Page = Scope:Computed(function(Use)
		return Pages[Use(Id)]
	end)
	local SafePage = Scope:Computed(function(Use)
		local PageValue = Use(Page) or {}

		return {
			Name = PageValue.Name or Use(Id),
			Icon = PageValue.Icon or "rbxassetid://13850086487",
		}
	end)

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Padding = {
			Left = Padding,
			Right = Padding,
			Top = Padding,
			Bottom = Padding,
		},
		List = {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
		},

		OnActivate = function()
			PanelsStateMod.ToPage(Panel, Fusion.peek(Id))
		end,

		[Children] = {
			Scope:Icon {
				Image = Scope:Computed(function(Use)
					return Use(SafePage).Icon
				end),
				ImageColor3 = Theme.Colors.BaseContent.Main,
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(Use(Theme.TextSize["1.875"]), Use(Theme.TextSize["1.875"]))
				end),
			},
			Scope:Text {
				Text = Scope:Computed(function(Use)
					return Use(SafePage).Name
				end),
				TextColor3 = Theme.Colors.BaseContent.Main,
				TextWrapped = false,
			},
		},
	}))
end
