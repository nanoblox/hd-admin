local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local Future = require(HDAdminUI.Parent.Parent.Packages.Future)
local CosmeticsStateMod = require(HDAdminUI.StateMods.CosmeticsStateMod)
local Config = require(HDAdminUI.Config)
local States = require(HDAdminUI.States)
local ColorUtils = require(HDAdminUI.Parent.Parent.Packages.ColorUtils)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = OnyxUI.GroupProps & {
	Id: Fusion.UsedAs<number>?,
	InfoType: Fusion.UsedAs<Enum.InfoType>?,
	OnToggle: Fusion.UsedAs<() -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Id = OnyxUI.Util.Fallback(Props.Id, nil)
	local InfoType = OnyxUI.Util.Fallback(Props.InfoType, Enum.InfoType.GamePass)
	local OnToggle = OnyxUI.Util.Fallback(Props.OnToggle, function() end)

	local Cosmetic = Scope:Computed(function(Use)
		return CONFIG.Cosmetics[Use(Id)]
	end)

	local ProductInfo = Scope:Value(nil)

	local SafeProductInfo = Scope:Computed(function(Use)
		local ProductInfoValue = Use(ProductInfo) or {}

		return {
			Name = ProductInfoValue.Name or "Product Name",
			Price = ProductInfoValue.PriceInRobux or 0,
			Icon = `rbxassetid://{ProductInfoValue.IconImageAssetId}`,
		}
	end)
	local Worn = Scope:Computed(function(Use)
		return table.find(Use(States.Perks.Cosmetics.Worn), Use(Id)) ~= nil
	end)

	local function UpdateInfo()
		Future.Try(function()
			local CosmeticValue = Fusion.peek(Cosmetic)
			local InfoTypeValue = Fusion.peek(InfoType)

			if CosmeticValue.ItemId then
				local Info = MarketplaceService:GetProductInfo(CosmeticValue.ItemId, InfoTypeValue)

				if Info then
					ProductInfo:set(Info)
				end
			end
		end)
	end

	task.spawn(function()
		UpdateInfo()
	end)
	Scope:Observer(Id):onChange(function()
		UpdateInfo()
	end)

	local Padding = Scope:UDim(0, Theme.Padding["0"])

	return Scope:Group(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},
		Stroke = {
			Color = Scope:Spring(
				Scope:Computed(function(Use)
					if Use(Worn) then
						return Use(Theme.Colors.Primary.Main)
					else
						return ColorUtils.Lighten(Use(Theme.Colors.Neutral.Main), Use(Theme.StrokeEmphasis.Regular))
					end
				end),
				Theme.SpringSpeed["1"],
				Theme.SpringDampening["1"]
			),
			Thickness = Scope:Computed(function(Use)
				if Use(Worn) then
					return Use(Theme.StrokeThickness["2"])
				else
					return Use(Theme.StrokeThickness["1"])
				end
			end),
			Gradient = {
				Enabled = Scope:Computed(function(Use)
					return not Use(Worn)
				end),
			},
		},

		[Children] = {
			Scope:CustomButton {
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					FillDirection = Enum.FillDirection.Vertical,
				},
				Padding = {
					Top = Padding,
					Left = Padding,
					Right = Padding,
					Bottom = Padding,
				},
				Stroke = {
					Enabled = false,
				},
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius["0"]),
				},

				OnActivate = function()
					local IdValue = Fusion.peek(Id)

					CosmeticsStateMod:Toggle(IdValue)

					OnToggle(Fusion.peek(Worn))
				end,

				[Children] = {
					Scope:Frame {
						Name = "Info",
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
							FillDirection = Enum.FillDirection.Vertical,
						},
						Padding = {
							All = Scope:UDim(0, Theme.Padding["0.75"]),
						},

						[Children] = {
							Scope:Image {
								Image = Scope:Computed(function(Use)
									return Use(SafeProductInfo).Icon
								end),
								BackgroundTransparency = 1,
								ScaleType = Enum.ScaleType.Fit,
							},
							Scope:Text {
								Text = Scope:Computed(function(Use)
									return Use(SafeProductInfo).Name
								end),
								FontFace = Scope:Computed(function(Use)
									return Font.new(Use(Theme.Font.Body), Use(Theme.FontWeight.Bold))
								end),
								Size = Scope:Computed(function(Use)
									return UDim2.fromOffset(0, Use(Theme.TextSize["1"]) * 2)
								end),
								MaxSize = Scope:Computed(function(Use)
									return Vector2.new(math.huge, Use(Theme.TextSize["1"]) * 2)
								end),
								TexTruncate = Enum.TextTruncate.AtEnd,
								TextXAlignment = Enum.TextXAlignment.Center,
								AutomaticSize = Enum.AutomaticSize.None,
								RichText = false,
							},
						},
					},
					Scope:Button {
						Name = "PurchaseButton",
						Color = Theme.Colors.Primary.Main,
						SizeVariant = "Large",
						ContentSize = Theme.TextSize["1"],
						Content = Scope:Computed(function(Use)
							return { ` {Use(SafeProductInfo).Price}` }
						end),
						Corner = {
							Radius = Scope:UDim(0, Theme.CornerRadius["0"]),
						},

						OnActivate = function()
							local InfoTypeValue = Fusion.peek(InfoType)
							local CosmeticValue = Fusion.peek(Cosmetic)

							Future.Try(function()
								if InfoTypeValue == Enum.InfoType.GamePass then
									MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, CosmeticValue.ItemId)
								elseif InfoTypeValue == Enum.InfoType.Product then
									MarketplaceService:PromptProductPurchase(Players.LocalPlayer, CosmeticValue.ItemId)
								elseif InfoTypeValue == Enum.InfoType.Asset then
									MarketplaceService:PromptPurchase(Players.LocalPlayer, CosmeticValue.ItemId)
								end
							end)
						end,
					},
				},
			},
		},
	}))
end
