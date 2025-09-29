--[[
	This is a Luau port of the excellent `color-blind` library by skratchdot.
	The original library is licensed under the MIT license.

	> https://github.com/skratchdot/color-blind/blob/master/lib/blind.js

	The `color-utils` adaptation is ported for use within Roblox's Luau library,
	but also contains TypeScript bindings for those using roblox-ts.
]]

type VectorXyY = {
	X: number,
	y: number,
	Y: number,
}

local Configs = require(script.Configs)
local Enums = require(script.Parent.Enum)

local function RGBtoXYZ(color: Color3): Vector3
	local M = Configs.Matrix.RGB_XYZ

	local r = color.R
	local g = color.G
	local b = color.B

	r = if r > 0.04 then ((r + 0.055) / 1.055) ^ 2.4 else r / 12.92
	g = if g > 0.04 then ((g + 0.055) / 1.055) ^ 2.4 else g / 12.92
	b = if b > 0.04 then ((b + 0.055) / 1.055) ^ 2.4 else b / 12.92

	return Vector3.new(r * M[1] + g * M[4] + b * M[7], r * M[2] + g * M[5] + b * M[8], r * M[3] + g * M[6] + b * M[9])
end

local function XYZtoXyY(vector: Vector3): VectorXyY
	local value = vector.X + vector.Y + vector.Z

	if value == 0 then
		return {
			X = 0,
			y = 0,
			Y = vector.Y,
		}
	end

	return {
		X = vector.X / value,
		y = vector.Y / value,
		Y = vector.Y,
	}
end

local function Anomalise(origin: Color3, blinded: Color3, multiplier: number?): Color3
	multiplier = if type(multiplier) == "number" then multiplier else 1.75

	local n = multiplier + 1

	return Color3.new(
		(multiplier * blinded.R + origin.R) / n,
		(multiplier * blinded.G + origin.G) / n,
		(multiplier * blinded.B + origin.B) / n
	)
end

--[=[
	@function Simulate
	@within Blind

	@param color Color3 -- The color to simulate.
	@param blinder Blind -- The blinder to simulate with.
	@return Color3 -- The simulated color.
]=]
local function SimulateBlinder(color: Color3, blinder: number): Color3
	assert(typeof(color) == "Color3", "Color must be a Color3")
	assert(typeof(blinder) == "number", "Blinder must be a number (see Enums.Blind)")

	local group = Configs.Groups[blinder]
	local anomalise = Configs.Anomalised[blinder]

	if group == Enums.Group.Trichroma then
		return color
	end

	if group == Enums.Group.Achroma then
		local val = color.R * 0.213 + color.G * 0.715 + color.B * 0.072
		local blinded = Color3.new(val, val, val)

		if anomalise then
			return Anomalise(color, blinded)
		end

		return blinded
	end

	local line = Configs.Blinder[group]
	local xyy = XYZtoXyY(RGBtoXYZ(color))

	local slope = (xyy.y - line.Y) / (xyy.X - line.X)
	local yi = xyy.y - xyy.X * slope

	local dX = (line.YI - yi) / (slope - line.M)
	local dy = (slope * dX) + yi
	local dY = 0

	local vector = {
		X = dX * xyy.Y / dy,
		Y = xyy.Y,
		Z = (1 - (dX + dy)) * xyy.Y / dy,
	}

	local ngx = 0.313 * xyy.Y / 0.329
	local ngz = 0.358 * xyy.Y / 0.329

	local dZ = ngz - vector.Z
	dX = ngx - vector.X

	local M = Configs.Matrix.XYZ_RGB

	local dR = dX * M[1] + dY * M[4] + dZ * M[7]
	local dG = dX * M[2] + dY * M[5] + dZ * M[8]
	local dB = dX * M[3] + dY * M[6] + dZ * M[9]

	vector.R = vector.X * M[1] + vector.Y * M[4] + vector.Z * M[7]
	vector.G = vector.X * M[2] + vector.Y * M[5] + vector.Z * M[8]
	vector.B = vector.X * M[3] + vector.Y * M[6] + vector.Z * M[9]

	local _r = ((if vector.R < 0 then 0 else 1) - vector.R) / dR
	local _g = ((if vector.G < 0 then 0 else 1) - vector.G) / dG
	local _b = ((if vector.B < 0 then 0 else 1) - vector.B) / dB

	_r = if _r > 1 or _r < 0 then 0 else _r
	_g = if _g > 1 or _g < 0 then 0 else _g
	_b = if _b > 1 or _b < 0 then 0 else _b

	local adjust = if _r > _g then _r else _g

	if _b > adjust then
		adjust = _b
	end

	vector.R += adjust * dR
	vector.G += adjust * dG
	vector.B += adjust * dB

	vector.R = 255 * (if vector.R <= 0 then 0 elseif vector.R >= 1 then 1 else vector.R ^ (1 / Configs.Gamma_Correct))
	vector.G = 255 * (if vector.G <= 0 then 0 elseif vector.G >= 1 then 1 else vector.G ^ (1 / Configs.Gamma_Correct))
	vector.B = 255 * (if vector.B <= 0 then 0 elseif vector.B >= 1 then 1 else vector.B ^ (1 / Configs.Gamma_Correct))

	local blinded = Color3.fromRGB(vector.R or 0, vector.G or 0, vector.B or 0)

	if anomalise then
		return Anomalise(color, blinded)
	end

	return blinded
end

return SimulateBlinder
