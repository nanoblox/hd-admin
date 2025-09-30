local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local UserInformant = require(UI.Utils.UserInformant)
local Sift = require(Packages.Sift)

local Children = Fusion.Children

local UserCheckButton = require(script.Parent.UserCheckButton)
local UserCheckbox = require(script.Parent.UserCheckbox)
local UserButton = require(script.Parent.UserButton)

export type Props = OnyxUI.FrameProps & {
	UserIds: Fusion.UsedAs<{ number }>?,
	PinnedUserIds: Fusion.UsedAs<{ number }>?,
	ButtonType: Fusion.UsedAs<"Checkbox" | "CheckButton" | "Button">?,
	Selection: Fusion.Value<{ number }>?,
	Search: Fusion.UsedAs<string>?,
	ButtonProps: Fusion.UsedAs<UserCheckButton.Props>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local UserIds = OnyxUI.Util.Fallback(Props.UserIds, {})
	local PinnedUserIds = OnyxUI.Util.Fallback(Props.PinnedUserIds, {})
	local ButtonType = OnyxUI.Util.Fallback(Props.ButtonType, "CheckButton")
	local Search = OnyxUI.Util.Fallback(Props.Search, "")
	local ButtonProps = OnyxUI.Util.Fallback(Props.ButtonProps, {})

	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, {}))

	local UserInfos = Scope:Value({})

	local function UpdateUserInfos()
		local CombinedUserIdsValue = Fusion.peek(UserIds)

		UserInfos:set(Sift.Array.map(CombinedUserIdsValue, function(UserId)
			return {
				UserId = UserId,
			}
		end))

		UserInfos:set(UserInformant.Users(CombinedUserIdsValue))
	end

	Scope:Observer(UserIds):onChange(function()
		UpdateUserInfos()
	end)
	task.spawn(function()
		UpdateUserInfos()
	end)

	local Component = Scope:Computed(function(Use)
		local ButtonTypeValue = Use(ButtonType)

		if ButtonTypeValue == "CheckButton" then
			return UserCheckButton
		elseif ButtonTypeValue == "Checkbox" then
			return UserCheckbox
		elseif ButtonTypeValue == "Button" then
			return UserButton
		end
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:ForValues(UserInfos, function(Use, Scope, UserInfo)
				local ComponentValue = Use(Component)
				local SearchValue = Use(Search)

				if
					(utf8.len(SearchValue) >= 1)
					and (string.match(string.lower(UserInfo.Username or ""), string.lower(SearchValue)) == nil)
				then
					return
				end

				local Checked = Scope:Value(false)

				local function UpdateChecked()
					Checked:set(table.find(Fusion.peek(Selection), UserInfo.UserId) ~= nil)
				end

				Scope:Observer(Selection):onChange(function()
					UpdateChecked()
				end)
				UpdateChecked()

				return OnyxUI.Themer.Theme:is(Theme):during(function()
					return ComponentValue(
						Scope,
						OnyxUI.Util.CombineProps(ButtonProps, {
							UserId = UserInfo.UserId,
							Checked = Checked,
							LayoutOrder = Scope:Computed(function(Use)
								local SelectionValue = Use(Selection)
								local PinnedUserIdsValue = Use(PinnedUserIds)
								local SelectionIndex = table.find(SelectionValue, UserInfo.UserId)
								local PinnedIndex = table.find(PinnedUserIdsValue, UserInfo.UserId)

								if PinnedIndex ~= nil then
									return PinnedIndex
								else
									return #PinnedUserIdsValue + string.byte(tostring(UserInfo.DisplayName))
								end
							end),

							OnCheck = function()
								local UserSelectionValue = Fusion.peek(Selection)

								local Index = table.find(UserSelectionValue, UserInfo.UserId)
								if Index ~= nil then
									table.remove(UserSelectionValue, Index)
								else
									table.insert(UserSelectionValue, UserInfo.UserId)
								end

								Selection:set(UserSelectionValue)
							end,
						})
					)
				end)
			end),
		},
	}))
end
