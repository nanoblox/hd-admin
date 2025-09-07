local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Fusion)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)
local States = require(HDAdminUI.States)
local UserInformant = require(HDAdminUI.Utils.UserInformant)
local Sift = require(HDAdminUI.Parent.Sift)

local Children = Fusion.Children

export type Props = OnyxUI.BaseButtonProps & {
	UserIds: Fusion.Value<{ number }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)

	local UserIds = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.UserIds, {}))
	local UserInfos = Scope:Value({})
	local Text = Scope:Value("")

	local function UpdateUserInfos()
		local UserIdsValue = Fusion.peek(UserIds) or {}

		UserInfos:set(Sift.Array.map(UserIdsValue, function(UserId)
			return {
				UserId = UserId,
			}
		end))

		UserInfos:set(UserInformant.Users(UserIdsValue))
	end
	local function UpdateText()
		local UserInfosValue = Fusion.peek(UserInfos)

		if #UserInfosValue > 0 then
			Text:set(`{table.concat(
				Sift.Array.map(UserInfosValue, function(Info: UserInformant.UserInfo)
					return Info.Username or `[{Info.UserId}]`
				end),
				", "
			)}`)
		else
			Text:set("Nobody")
		end
	end

	Scope:Observer(UserIds):onChange(function()
		UpdateUserInfos()
	end)
	Scope:Observer(UserInfos):onChange(function()
		UpdateText()
	end)
	task.spawn(function()
		UpdateUserInfos()
		UpdateText()
	end)

	return Scope:BaseButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
		},

		OnActivate = function()
			local UserIdsValue = Fusion.peek(UserIds) or {}

			Text:set("")

			States.Menu.Pages.Users.Selected:set(UserIdsValue)
			NavigationStateMod:To("Users")

			States.Menu.Pages.Users.SelectedCallback:set(function(SelectedUserIds: { number })
				UserIds:set(SelectedUserIds or {})
			end)
		end,

		[Children] = {
			Scope:TextInput {
				Text = Text,
				PlaceholderText = Text,
				TextEditable = false,
				Active = false,
				Selectable = false,
				Interactable = false,
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},
			},
		},
	}))
end
