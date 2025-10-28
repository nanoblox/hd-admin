local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)
local Sift = require(Packages.Sift)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local UserStateMod = require(UI.StateMods.UserStateMod)

local Children = Fusion.Children

export type Props = OnyxUI.BaseButtonProps & {
	UserIds: Fusion.Value<{ number }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Panel = PanelsStateMod.Panel:now()

	local UserIds = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.UserIds, {}))

	local UserInfos = Scope:ForValues(UserIds, function(Use, Scope, UserId)
		return UserStateMod.GetSafe(Scope, UserStateMod.Get(Scope, UserId))
	end)
	local Text = Scope:Computed(function(Use)
		local UserInfosValue = Use(UserInfos)

		if #UserInfosValue > 0 then
			return `{table.concat(
				Sift.Array.map(UserInfosValue, function(UserInfo)
					local UserInfoValue = Use(UserInfo)

					return UserInfoValue.Username or `[{UserInfoValue.UserId}]`
				end),
				", "
			)}`
		else
			return "Nobody"
		end
	end)

	return Scope:BaseButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
		},

		OnActivate = function()
			local UserIdsValue = Fusion.peek(UserIds) or {}

			Panel.PagesData.Users.Selected:set(UserIdsValue)
			PanelsStateMod.ToPage(Panel, "Users")

			Panel.PagesData.Users.SelectedCallback:set(function(SelectedUserIds: { number })
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
