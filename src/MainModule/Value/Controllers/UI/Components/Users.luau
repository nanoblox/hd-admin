local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local UserInformant = require(UI.Utils.UserInformant)
local UserStateMod = require(UI.StateMods.UserStateMod)

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
	local Panel = PanelsStateMod.Panel:now()

	local UserIds = OnyxUI.Util.Fallback(Props.UserIds, {})
	local PinnedUserIds = OnyxUI.Util.Fallback(Props.PinnedUserIds, {})
	local ButtonType = OnyxUI.Util.Fallback(Props.ButtonType, "CheckButton")
	local Search = OnyxUI.Util.Fallback(Props.Search, "")
	local ButtonProps = OnyxUI.Util.Fallback(Props.ButtonProps, function()
		return {}
	end)
	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, {}))

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
	local UserInfos = Scope:ForValues(UserIds, function(Use, Scope, UserId: number)
		return UserStateMod.GetSafe(Scope, UserStateMod.Get(Scope, UserId))
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:ForValues(UserInfos, function(Use, Scope, UserInfo)
				local UserInfoValue = Fusion.peek(UserInfo)
				local ComponentValue = Use(Component)
				local SearchValue = Use(Search)

				if
					(utf8.len(SearchValue) >= 1)
					and (string.match(string.lower(UserInfoValue.Username or ""), string.lower(SearchValue)) == nil)
				then
					return
				end

				local Checked = Scope:Value(false)

				local function UpdateChecked()
					Checked:set(table.find(Fusion.peek(Selection), UserInfoValue.UserId) ~= nil)
				end

				Scope:Observer(Selection):onChange(function()
					UpdateChecked()
				end)
				UpdateChecked()

				return OnyxUI.Themer.Theme:is(Theme):during(function()
					return PanelsStateMod.Panel:is(Panel):during(function()
						return ComponentValue(
							Scope,
							OnyxUI.Util.CombineProps(ButtonProps(UserInfoValue), {
								UserId = UserInfoValue.UserId,
								Checked = Checked,
								LayoutOrder = Scope:Computed(function(Use)
									local PinnedUserIdsValue = Use(PinnedUserIds)
									local PinnedIndex = table.find(PinnedUserIdsValue, UserInfoValue.UserId)

									if PinnedIndex ~= nil then
										return PinnedIndex
									else
										return #PinnedUserIdsValue + string.byte(tostring(UserInfoValue.DisplayName))
									end
								end),

								OnCheck = function()
									local UserSelectionValue = Fusion.peek(Selection)

									local Index = table.find(UserSelectionValue, UserInfoValue.UserId)
									if Index ~= nil then
										table.remove(UserSelectionValue, Index)
									else
										table.insert(UserSelectionValue, UserInfoValue.UserId)
									end

									Selection:set(UserSelectionValue)
								end,
							})
						)
					end)
				end)
			end),
		},
	}))
end
