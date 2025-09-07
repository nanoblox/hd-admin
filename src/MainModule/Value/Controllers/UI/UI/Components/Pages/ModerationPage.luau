local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)
local UserInformant = require(HDAdminUI.Utils.UserInformant)
local States = require(HDAdminUI.States)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Users = require(script.Parent.Parent.Users)
local IconSwapper = require(script.Parent.Parent.IconSwapper)

export type Props = OnyxUI.FrameProps & {
	Open: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		IconSwapper = IconSwapper,
		Users = Users,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local TabMode = Scope:Value(1)
	local SearchQuery = Scope:Value("")
	local UserSelection = Scope:Value({})
	local ActiveUserInfos = Scope:Value({})

	local BannedUsers = Scope:Computed(function(Use)
		local UserProfilesValue = Use(States.Users.Profiles)

		return Sift.Dictionary.keys(Sift.Dictionary.filter(UserProfilesValue, function(Profile, UserId)
			if Profile.Banned then
				return UserId
			else
				return nil
			end
		end))
	end)
	local WarnedUsers = Scope:Computed(function(Use)
		local UserProfilesValue = Use(States.Users.Profiles)

		return Sift.Dictionary.keys(Sift.Dictionary.filter(UserProfilesValue, function(Profile, UserId)
			if #Profile.Warnings > 0 then
				return UserId
			else
				return nil
			end
		end))
	end)
	local ActiveUsers = Scope:Computed(function(Use)
		local TabModeValue = Use(TabMode)

		local ModeUserMap = { BannedUsers, WarnedUsers }

		return Use(ModeUserMap[TabModeValue])
	end)

	local function UpdateUserInfos()
		local UserIdsValue = Fusion.peek(ActiveUsers)

		ActiveUserInfos:set(Sift.Array.map(UserIdsValue, function(UserId)
			return {
				UserId = UserId,
			}
		end))

		ActiveUserInfos:set(UserInformant.Users(UserIdsValue))
	end

	Scope:Observer(ActiveUsers):onChange(function()
		UpdateUserInfos()
	end)
	task.spawn(function()
		UpdateUserInfos()
	end)

	Scope:Observer(TabMode):onChange(function()
		UserSelection:set({})
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Frame {
				Name = "Filters",
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:Frame {
						Name = "SearchBar",
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalFlex = Enum.UIFlexAlignment.Fill,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
						},

						[Children] = {
							Scope:TextInput {
								Name = "SearchInput",
								PlaceholderText = "Search",
								Text = SearchQuery,
								Flex = {
									Mode = Enum.UIFlexMode.Fill,
								},
							},
							Scope:IconButton {
								Name = "AddRecordButton",
								Image = CONFIG.Icons.Add,
								Aspect = {
									Ratio = 1,
									Type = Enum.AspectType.ScaleWithParentSize,
								},

								OnActivate = function()
									local TabModeValue = Fusion.peek(TabMode)

									local TabModeCommand = { "Ban", "Warn" }

									NavigationStateMod:To("Execute")
									States.Menu.Pages.Execute.CommandId:set(TabModeCommand[TabModeValue])
								end,
							},
						},
					},

					Scope:Tabs {
						Tabs = {
							{ CONFIG.Icons.ProhibitedFill, "Bans" },
							{ CONFIG.Icons.WarningFill, "Warns" },
						},
						Tab = TabMode,
						ButtonProps = {
							SizeVariant = "Large",
							ContentSize = Theme.TextSize["1"],
						},
						Stroke = {
							Enabled = false,
						},
						List = {
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
						},
					},
				},
			},
			Scope:Scroller {
				Name = "Users",
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					Scope:Users {
						UserIds = ActiveUsers,
						Selection = UserSelection,
						ButtonType = "CheckButton",
						Search = SearchQuery,
					},
				},
			},
			Scope:Frame {
				Name = "PrimaryButton",
				Visible = Scope:Computed(function(Use)
					return #Use(UserSelection) > 0
				end),
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},

				[Children] = {
					Scope:Button {
						Name = "UndoButton",
						Content = Scope:Computed(function(Use)
							local UserSelectionValue = Use(UserSelection)
							local TabModeValue = Use(TabMode)
							local ActionName = (TabModeValue == 1 and "Unban") or "Unwarn"

							return { `{ActionName} {#UserSelectionValue}` }
						end),
						Color = Theme.Colors.Primary.Main,
						SizeVariant = "ExtraLarge",
						ContentSize = Theme.TextSize["1"],
					},
				},
			},
		},
	}))
end
