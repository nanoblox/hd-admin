local Players = game:GetService("Players")

local LOCAL_USER_ID = Players.LocalPlayer and Players.LocalPlayer.UserId or 1

local Donators = {
	Top = {
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
		{
			UserId = 1,
			Amount = 10000,
		},
	},
	Recent = {
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
		{
			UserId = 2,
			Amount = 10,
		},
	},
	Local = {
		UserId = LOCAL_USER_ID,
		Amount = 0,
	},
}

return Donators
