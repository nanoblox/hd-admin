local RunService = game:GetService("RunService")
local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local States = require(HDAdminUI.States)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)
local UserInformant = require(HDAdminUI.Utils.UserInformant)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)

local Children = Fusion.Children

local UserCheckbox = require(script.Parent.Parent.UserCheckbox)
local CustomButton = require(script.Parent.Parent.CustomButton)
local Users = require(script.Parent.Parent.Users)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		UserCheckbox = UserCheckbox,
		CustomButton = CustomButton,
		Users = Users,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local UserSelection = States.Menu.Pages.Users.Selected
	local SearchQuery = Scope:Value("")
	local UsernameIdResult = Scope:Value(nil)

	local UserIds = Scope:Computed(function(Use)
		local PlayersValue = Use(States.Session.Players)

		if RunService:IsRunning() then
			return Sift.Array.map(Sift.Array.prepend(PlayersValue), function(Player: Player)
				return Player.UserId
			end)
		else
			return Sift.Array.prepend({ 1, 2, 3, 4 })
		end
	end)

	local function UpdateUsernameResult(Username: string)
		local UserId = UserInformant.UserIdFromUsername(Username)

		if UserId then
			UsernameIdResult:set(UserId)
		end
	end

	Scope:Observer(SearchQuery):onChange(function()
		UsernameIdResult:set(nil)
	end)

	Scope:Observer(States.Menu.Page):onChange(function()
		local UserSelectionValue = Fusion.peek(UserSelection)
		local SelectedCallbackValue = Fusion.peek(States.Menu.Pages.Users.SelectedCallback)

		if SelectedCallbackValue then
			SelectedCallbackValue(UserSelectionValue)
		end
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:TextInput {
				Name = "SearchInput",
				PlaceholderText = "Search",
				Text = SearchQuery,

				OnFocusEnd = function()
					UpdateUsernameResult(Fusion.peek(SearchQuery))
				end,
			},
			Scope:Scroller {
				Name = "Users",
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					Scope:Frame {
						Name = "Users",
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
						},

						[Children] = {
							Scope:ForValues({
								{
									Title = "Roblox",
									UserIds = Scope:Computed(function(Use)
										local UsernameIdResultValue = Use(UsernameIdResult)
										local UserSelectionValue = Use(UserSelection)
										local UserIdsValue = Use(UserIds)

										return Sift.Array.difference(
											Sift.Array.join({ UsernameIdResultValue }, UserSelectionValue),
											UserIdsValue
										)
									end),
								},
								{
									Title = "In-game",
									UserIds = UserIds,
								},
							}, function(Use, Scope, UserSort)
								return Scope:Frame {
									Name = "UserSort",
									Visible = Scope:Computed(function(Use)
										return #Use(UserSort.UserIds) > 0
									end),
									List = {
										HorizontalFlex = Enum.UIFlexAlignment.Fill,
									},

									[Children] = {
										Scope:Heading {
											Text = UserSort.Title,
											TextSize = Theme.TextSize["1.25"],
										},
										Scope:Users {
											UserIds = UserSort.UserIds,
											Selection = UserSelection,
											ButtonType = "Checkbox",
											LayoutOrder = 1,
										},
									},
								}
							end),
						},
					},
				},
			},
			Scope:Button {
				Name = "ConfirmButton",
				Content = Scope:Computed(function(Use)
					local UserSelectionValue = Use(UserSelection)

					if #UserSelectionValue >= 1 then
						return { `Confirm ({#UserSelectionValue})` }
					else
						return { `Confirm` }
					end
				end),
				Color = Scope:Computed(function(Use)
					local UserSelectionValue = Use(UserSelection)

					if #UserSelectionValue > 0 then
						return Use(Theme.Colors.Primary.Main)
					else
						return Use(Theme.Colors.Neutral.Main)
					end
				end),
				SizeVariant = "ExtraLarge",
				ContentSize = Theme.TextSize["1"],
				Corner = {},

				OnActivate = function()
					NavigationStateMod:Undo()
				end,
			},
		},
	}))
end
