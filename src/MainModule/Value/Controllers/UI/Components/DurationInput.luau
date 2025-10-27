local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages

local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)

local Children = Fusion.Children

local NumberInput = require(script.Parent.NumberInput)

export type Props = OnyxUI.BaseProps & {
	Time: Fusion.Value<number>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		NumberInput = NumberInput,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Time = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Time, 0))

	local TimeProperties = {
		{
			Name = "Day.",
			Unit = 60 ^ 2 * 24,
			Value = Scope:Value(0),
		},
		{
			Name = "Hr.",
			Unit = 60 ^ 2,
			Value = Scope:Value(0),
		},
		{
			Name = "Min.",
			Unit = 60,
			Value = Scope:Value(0),
		},
		{
			Name = "Sec.",
			Unit = 1,
			Value = Scope:Value(0),
		},
	}

	local function UpdateTotalTime()
		local TotalTime = 0

		for _, TimeProperty in TimeProperties do
			local NumberValue = Fusion.peek(TimeProperty.Value)
			local ValueInSeconds = math.floor((NumberValue or 1) * TimeProperty.Unit)

			TotalTime += ValueInSeconds
		end

		Time:set(TotalTime)
	end
	local function UpdateTimeProperties()
		local TimeValue = Fusion.peek(Time)
		local TimeLeft = TimeValue

		for _, TimeProperty in TimeProperties do
			local ValueInUnits = math.floor((TimeLeft or 1) / TimeProperty.Unit)

			TimeProperty.Value:set(ValueInUnits)

			TimeLeft -= ValueInUnits * TimeProperty.Unit
		end
	end

	Scope:Observer(Time):onChange(function()
		UpdateTimeProperties()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},

		[Children] = {
			Scope:ForValues(TimeProperties, function(Use, Scope, TimeProperty)
				local Number = Scope:Value(0)

				Scope:Observer(TimeProperty.Value):onChange(function()
					local NewValue = Fusion.peek(TimeProperty.Value)

					Number:set(tostring(NewValue or 0))
				end)

				return OnyxUI.Themer.Theme:is(Theme):during(function()
					return Scope:Frame {
						Name = "TimeInput",
						List = {
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
						},

						[Children] = {
							Scope:NumberInput {
								Number = Number,
								Minimum = 0,
								Round = true,
								AutomaticSize = Enum.AutomaticSize.Y,
								ClearTextOnFocus = true,
								OnFocusEnd = function(NewNumber: number)
									TimeProperty.Value:set(NewNumber)

									UpdateTotalTime()
								end,
							},
							Scope:Text {
								Text = TimeProperty.Name,
								TextColor3 = Theme.Colors.NeutralContent.Dark,
								TextXAlignment = Enum.TextXAlignment.Center,
							},
						},
					}
				end)
			end),
		},
	}))
end
