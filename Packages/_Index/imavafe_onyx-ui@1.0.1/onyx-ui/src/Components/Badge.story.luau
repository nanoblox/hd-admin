local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Children = Fusion.Children

local Frame = require(OnyxUI.Components.Frame)
local Badge = require(OnyxUI.Components.Badge)
local Text = require(OnyxUI.Components.Text)
local Components = {
	Frame = Frame,
	Badge = Badge,
	Text = Text,
}

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local NotificationCount = Scope:Value(0)

		local CountThread = task.spawn(function()
			while task.wait(0.08) do
				if Fusion.peek(NotificationCount) == 100 then
					task.wait(3)
					NotificationCount:set(1)
				else
					NotificationCount:set(Fusion.peek(NotificationCount) + 1)
				end
			end
		end)

		Scope:innerScope({
			function()
				task.cancel(CountThread)
			end,
		})

		Scope:Frame {
			Parent = Props.target,
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			},

			[Children] = {
				Scope:Badge {
					Content = { "Badge" },
				},
				Scope:Badge {
					Content = { "rbxassetid://103798699021677", "-50%" },
					Color = Util.Colors.Red["500"],
				},
				Scope:Badge {
					Content = { "rbxassetid://140490867216758", "LIMITED" },
					Color = Util.Colors.Red["500"],
				},
				Scope:Badge {
					Content = Scope:Computed(function(Use)
						if Use(NotificationCount) >= 100 then
							return { "99+" }
						else
							return { Use(NotificationCount) }
						end
					end),
					Color = Theme.Colors.Primary.Main,
				},
				Scope:Frame {
					List = {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
					},

					[Children] = {
						Scope:Text {
							Text = "It's also proportional alongside text.",
						},
						Scope:Badge {
							Content = { "rbxassetid://137979359742656", "TRUE" },
							Color = Util.Colors.Green["500"],
						},
					},
				},
			},
		}
	end,
	fusion = Fusion,
}
