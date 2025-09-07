local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)

local CONFIG = Config:Get()

export type Props = OnyxUI.ButtonProps & {
	Id: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Id = OnyxUI.Util.Fallback(Props.Id, CONFIG.DonationProducts)

	local Donation = Scope:Computed(function(Use)
		return CONFIG.DonationProducts[Use(Id)]
	end)
	local DonationSafe = Scope:Computed(function(Use)
		local DonationValue = Use(Donation)

		return Sift.Dictionary.merge(DonationValue, {
			Amount = 0,
			ProductId = nil,
		})
	end)

	return Scope:Button(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Content = Scope:Computed(function(Use)
			local IdValue = Use(Id)

			return { ` {IdValue}` }
		end),
		ContentSize = Theme.TextSize["1"],
		SizeVariant = "ExtraLarge",

		OnActivate = function()
			local DonationSafeValue = Fusion.peek(DonationSafe)

			if (Players.LocalPlayer ~= nil) and (DonationSafeValue.ProductId ~= nil) then
				MarketplaceService:PromptProductPurchase(Players.LocalPlayer, DonationSafeValue.ProductId)
			end
		end,
	}))
end
