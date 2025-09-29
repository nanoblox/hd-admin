local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local ThemeSpec = require(script.Parent.ThemeSpec)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)
local Util = require(OnyxUI.Util)

export type ThemeSpec = ThemeSpec.ThemeSpec

local function ReconcileValues(Target: { [string]: Fusion.UsedAs<any> }, Source: { [string]: any })
	for Key, Value in pairs(Target) do
		if typeof(Value) == "table" and Value.set then
			if typeof(Source[Key]) == "table" and Source[Key].get then
				Value:set(Fusion.peek(Source[Key]))
			elseif Source[Key] ~= nil then
				Value:set(Source[Key])
			end
		elseif typeof(Value) == "table" then
			if typeof(Source[Key]) == "table" then
				ReconcileValues(Value, Source[Key])
			end
		end
	end
end

local function ProcessColors(ThemeObject)
	for _, ColorObject in pairs(ThemeObject.Colors) do
		local MainValue = Fusion.peek(ColorObject.Main)
		if MainValue ~= nil then
			if Fusion.peek(ColorObject.Contrast) == nil then
				ColorObject.Contrast:set(Util.Emphasize(MainValue, Fusion.peek(ThemeObject.Emphasis.Contrast)))
			end

			if Fusion.peek(ColorObject.Dark) == nil then
				ColorObject.Dark:set(ColorUtils.Darken(MainValue, Fusion.peek(ThemeObject.Emphasis.Strong)))
			end

			if Fusion.peek(ColorObject.Light) == nil then
				ColorObject.Light:set(ColorUtils.Lighten(MainValue, Fusion.peek(ThemeObject.Emphasis.Strong)))
			end
		end
	end
end

local function ProcessEmphasis(Objects)
	local BaseEmphasis = Fusion.peek(Objects.Regular)

	Objects.Light:set(BaseEmphasis * 2 / 3)
	Objects.Strong:set(BaseEmphasis * 2)
end

local function ProcessMultipliers(Objects: {
	Base: Fusion.Value<Fusion.Scope<any>, number>,
	[string]: Fusion.Value<Fusion.Scope<any>, number>,
})
	local Base = Fusion.peek(Objects.Base)
	for Key, Value in pairs(Objects) do
		if Fusion.peek(Value) == nil then
			local Multiplier = tonumber(Key)
			if Multiplier ~= nil then
				Value:set(Base * Multiplier)
			end
		end
	end

	if Objects.Full ~= nil then
		Objects.Full:set(Base * 10000)
	end
end

local function NewTheme(Scope: Fusion.Scope<any>, ThemeSpec: ThemeSpec)
	local Scope = Fusion.innerScope(Scope, Fusion)

	local ThemeObject = {
		Colors = {
			Primary = {
				Main = Scope:Value(Util.Colors.Black),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			Secondary = {
				Main = Scope:Value(Util.Colors.Black),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			Accent = {
				Main = Scope:Value(Util.Colors.Black),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},

			Neutral = {
				Main = Scope:Value(Util.Colors.Gray["300"]),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			NeutralContent = {
				Main = Scope:Value(Util.Colors.Gray["800"]),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},

			Base = {
				Main = Scope:Value(Util.Colors.White),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			BaseContent = {
				Main = Scope:Value(Util.Colors.Black),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},

			Success = {
				Main = Scope:Value(Util.Colors.Green["400"]),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			Error = {
				Main = Scope:Value(Util.Colors.Red["400"]),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			Warning = {
				Main = Scope:Value(Util.Colors.Orange["400"]),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
			Info = {
				Main = Scope:Value(Util.Colors.Blue["400"]),
				Dark = Scope:Value(nil),
				Light = Scope:Value(nil),
				Contrast = Scope:Value(nil),
			},
		},
		Font = {
			Body = Scope:Value("GothamSsm"),
			Heading = Scope:Value("GothamSsm"),
			Monospace = Scope:Value("GothamSsm"),
		},
		FontWeight = {
			Body = Scope:Value(Enum.FontWeight.Regular),
			Bold = Scope:Value(Enum.FontWeight.Bold),
			Heading = Scope:Value(Enum.FontWeight.Bold),
		},
		TextSize = {
			Base = Scope:Value(16),
			["0.75"] = Scope:Value(nil),
			["0.875"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.125"] = Scope:Value(nil),
			["1.25"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["1.875"] = Scope:Value(nil),
			["2.25"] = Scope:Value(nil),
			["3"] = Scope:Value(nil),
			["3.75"] = Scope:Value(nil),
			["4.5"] = Scope:Value(nil),
		},
		Padding = {
			Base = Scope:Value(16),
			["0"] = Scope:Value(0),
			["0.25"] = Scope:Value(nil),
			["0.5"] = Scope:Value(nil),
			["0.75"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			["3"] = Scope:Value(nil),
			["4"] = Scope:Value(nil),
			["6"] = Scope:Value(nil),
			["8"] = Scope:Value(nil),
			["12"] = Scope:Value(nil),
			["16"] = Scope:Value(nil),
			["20"] = Scope:Value(nil),
			["24"] = Scope:Value(nil),
			["28"] = Scope:Value(nil),
			["32"] = Scope:Value(nil),
			["36"] = Scope:Value(nil),
			["40"] = Scope:Value(nil),
			["44"] = Scope:Value(nil),
			["48"] = Scope:Value(nil),
		},
		Spacing = {
			Base = Scope:Value(22),
			["0"] = Scope:Value(0),
			["0.25"] = Scope:Value(nil),
			["0.5"] = Scope:Value(nil),
			["0.75"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			["3"] = Scope:Value(nil),
			["4"] = Scope:Value(nil),
			["6"] = Scope:Value(nil),
			["8"] = Scope:Value(nil),
			["12"] = Scope:Value(nil),
			["16"] = Scope:Value(nil),
			["20"] = Scope:Value(nil),
			["24"] = Scope:Value(nil),
			["28"] = Scope:Value(nil),
			["32"] = Scope:Value(nil),
			["36"] = Scope:Value(nil),
			["40"] = Scope:Value(nil),
			["44"] = Scope:Value(nil),
			["48"] = Scope:Value(nil),
		},
		Sizing = {
			Base = Scope:Value(22),
			["0"] = Scope:Value(0),
			["0.25"] = Scope:Value(nil),
			["0.5"] = Scope:Value(nil),
			["0.75"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			["3"] = Scope:Value(nil),
			["4"] = Scope:Value(nil),
			["6"] = Scope:Value(nil),
			["8"] = Scope:Value(nil),
			["12"] = Scope:Value(nil),
			["16"] = Scope:Value(nil),
			["20"] = Scope:Value(nil),
			["24"] = Scope:Value(nil),
			["28"] = Scope:Value(nil),
			["32"] = Scope:Value(nil),
			["36"] = Scope:Value(nil),
			["40"] = Scope:Value(nil),
			["44"] = Scope:Value(nil),
			["48"] = Scope:Value(nil),
		},
		CornerRadius = {
			Base = Scope:Value(4),
			["0"] = Scope:Value(0),
			["0.5"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			["3"] = Scope:Value(nil),
			["4"] = Scope:Value(nil),
			["6"] = Scope:Value(nil),
			Full = Scope:Value(nil),
		},
		StrokeThickness = {
			Base = Scope:Value(2),
			["0"] = Scope:Value(0),
			["1"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			["3"] = Scope:Value(nil),
			["4"] = Scope:Value(nil),
			["8"] = Scope:Value(nil),
		},
		StrokeEmphasis = {
			Regular = Scope:Value(0.1),
			Light = Scope:Value(nil),
			Strong = Scope:Value(nil),
			Contrast = Scope:Value(1),
		},
		SpringSpeed = {
			Base = Scope:Value(40),
			["0.1"] = Scope:Value(nil),
			["0.175"] = Scope:Value(nil),
			["0.25"] = Scope:Value(nil),
			["0.375"] = Scope:Value(nil),
			["0.5"] = Scope:Value(nil),
			["0.75"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			Immediate = Scope:Value(1000),
		},
		SpringDampening = {
			Base = Scope:Value(1),
			["0.1"] = Scope:Value(nil),
			["0.175"] = Scope:Value(nil),
			["0.25"] = Scope:Value(nil),
			["0.375"] = Scope:Value(nil),
			["0.5"] = Scope:Value(nil),
			["0.75"] = Scope:Value(nil),
			["1"] = Scope:Value(nil),
			["1.5"] = Scope:Value(nil),
			["2"] = Scope:Value(nil),
			["5"] = Scope:Value(nil),
			["10"] = Scope:Value(nil),
			Full = Scope:Value(1000),
		},
		Sound = {
			Hover = Scope:Value(Scope:New "Sound" {
				SoundId = "rbxassetid://10066936758",
				Volume = 0.05,
			}),
			Click = Scope:Value(Scope:New "Sound" {
				SoundId = "rbxassetid://16480549841",
				Volume = 0.5,
			}),
			Focus = Scope:Value(Scope:New "Sound" {
				SoundId = "rbxassetid://16480549841",
				Volume = 0.5,
			}),
			Switch = Scope:Value(Scope:New "Sound" {
				SoundId = "rbxassetid://9119713951",
				Volume = 0.5,
			}),
		},
		Emphasis = {
			Regular = Scope:Value(0.2),
			Light = Scope:Value(nil),
			Strong = Scope:Value(nil),
			Contrast = Scope:Value(1),
		},
	}

	ReconcileValues(ThemeObject, ThemeSpec)

	ProcessEmphasis(ThemeObject.Emphasis)
	ProcessEmphasis(ThemeObject.StrokeEmphasis)
	ProcessColors(ThemeObject)
	ProcessMultipliers(ThemeObject.Padding)
	ProcessMultipliers(ThemeObject.Spacing)
	ProcessMultipliers(ThemeObject.Sizing)
	ProcessMultipliers(ThemeObject.TextSize)
	ProcessMultipliers(ThemeObject.CornerRadius)
	ProcessMultipliers(ThemeObject.StrokeThickness)
	ProcessMultipliers(ThemeObject.SpringSpeed)
	ProcessMultipliers(ThemeObject.SpringDampening)

	return ThemeObject
end

return NewTheme
