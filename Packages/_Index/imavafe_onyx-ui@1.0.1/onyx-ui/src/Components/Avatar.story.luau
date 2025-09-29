local OnyxUI = script.Parent.Parent

local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Themer)
local Util = require(OnyxUI.Util)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local Avatar = require(script.Parent.Avatar)
local Components = {
	Frame = Frame,
	Avatar = Avatar,
}

local INDICATOR_COLORS =
	{ Util.Colors.Red["500"], Util.Colors.Green["400"], Util.Colors.Orange["500"], Util.Colors.Stone["600"] }

return {
	story = function(Props)
		local Scope = Fusion.innerScope(Props.scope, Fusion, Util, Components)
		local Theme = Themer.Theme:now()

		local IndicatorColor = Scope:Value(INDICATOR_COLORS[2])
		local RingThickness = Scope:Value(Fusion.peek(Theme.StrokeThickness["2"]))

		local RandomizerThread = task.spawn(function()
			while task.wait(1) do
				IndicatorColor:set(INDICATOR_COLORS[math.random(1, #INDICATOR_COLORS)])

				if Fusion.peek(RingThickness) == Fusion.peek(Theme.StrokeThickness["2"]) then
					RingThickness:set(Fusion.peek(Theme.StrokeThickness["3"]))
				else
					RingThickness:set(Fusion.peek(Theme.StrokeThickness["2"]))
				end
			end
		end)

		Scope:innerScope({
			function()
				task.cancel(RandomizerThread)
			end,
		})

		Scope:Frame {
			Parent = Props.target,
			Padding = {
				All = Scope:UDim(0, Theme.StrokeThickness["4"]),
			},
			List = {
				Padding = Scope:UDim(0, Theme.Spacing["1"]),
				FillDirection = Enum.FillDirection.Horizontal,
			},

			[Children] = {
				Scope:Avatar {
					Image = "rbxthumb://type=AvatarHeadShot&id=144146784&w=150&h=150",
				},
				Scope:Avatar {
					Image = "rbxthumb://type=AvatarHeadShot&id=144146784&w=150&h=150",
					Corner = {
						Radius = Scope:UDim(0, Theme.CornerRadius.Full),
					},
				},
				Scope:Avatar {
					Image = "rbxthumb://type=AvatarHeadShot&id=144146784&w=150&h=150",
					Corner = {
						Radius = Scope:UDim(0, Theme.CornerRadius.Full),
					},
					RingEnabled = true,
					RingColor = IndicatorColor,
				},
				Scope:Avatar {
					Image = "rbxthumb://type=AvatarHeadShot&id=144146784&w=150&h=150",
					Corner = {
						Radius = Scope:UDim(0, Theme.CornerRadius.Full),
					},
					IndicatorEnabled = true,
					IndicatorColor = IndicatorColor,
				},
				Scope:Avatar {
					Image = "rbxthumb://type=AvatarHeadShot&id=144146784&w=150&h=150",
					Corner = {
						Radius = Scope:UDim(0, Theme.CornerRadius.Full),
					},
					RingEnabled = true,
					RingColor = Util.Colors.Green["400"],
					RingThickness = RingThickness,
				},
				Scope:Avatar {
					Image = "rbxthumb://type=AvatarHeadShot&id=144146784&w=150&h=150",
					Corner = {
						Radius = Scope:UDim(0, Theme.CornerRadius.Full),
					},
					IndicatorEnabled = true,
					IndicatorColor = Util.Colors.Sky["500"],
					IndicatorIcon = "rbxassetid://13805569043",
				},
			},
		}
	end,
	fusion = Fusion,
}
