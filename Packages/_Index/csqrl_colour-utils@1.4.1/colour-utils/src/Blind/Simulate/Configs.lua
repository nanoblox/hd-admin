local Enums = require(script.Parent.Parent.Enum)

local ANOMALISED = {
	[Enums.Blind.Protanomaly] = true,
	[Enums.Blind.Deuteranomaly] = true,
	[Enums.Blind.Tritanomaly] = true,
	[Enums.Blind.Achromatomaly] = true,
}

local GROUPS = {
	[Enums.Blind.Trichromacy] = Enums.Group.Trichroma,
	[Enums.Blind.Protanopia] = Enums.Group.Protan,
	[Enums.Blind.Protanomaly] = Enums.Group.Protan,
	[Enums.Blind.Deuteranopia] = Enums.Group.Deutan,
	[Enums.Blind.Deuteranomaly] = Enums.Group.Deutan,
	[Enums.Blind.Tritanopia] = Enums.Group.Tritan,
	[Enums.Blind.Tritanomaly] = Enums.Group.Tritan,
	[Enums.Blind.Achromatopsia] = Enums.Group.Achroma,
	[Enums.Blind.Achromatomaly] = Enums.Group.Achroma,
}

local GAMMA_CORRECT = 2.2

local MATRIX_XYZ_RGB = {
	3.241,
	-0.969,
	0.056,
	-1.537,
	1.876,
	-0.204,
	-0.499,
	0.042,
	1.057,
}

local MATRIX_RGB_XYZ = {
	0.412,
	0.213,
	0.019,
	0.358,
	0.715,
	0.119,
	0.18,
	0.072,
	0.95,
}

local BLINDER = {
	[Enums.Group.Protan] = {
		X = 0.747,
		Y = 0.254,
		M = 1.273,
		YI = -0.074,
	},
	[Enums.Group.Deutan] = {
		X = 1.4,
		Y = -0.4,
		M = 0.968,
		YI = 0.003,
	},
	[Enums.Group.Tritan] = {
		X = 0.175,
		Y = 0,
		M = 0.063,
		YI = 0.292,
	},
}

return {
	Anomalised = ANOMALISED,
	Groups = GROUPS,
	Gamma_Correct = GAMMA_CORRECT,
	Matrix = {
		XYZ_RGB = MATRIX_XYZ_RGB,
		RGB_XYZ = MATRIX_RGB_XYZ,
	},
	Blinder = BLINDER,
}
