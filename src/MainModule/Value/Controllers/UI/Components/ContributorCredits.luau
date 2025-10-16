local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local UserInformant = require(UI.Utils.UserInformant)
local Config = require(UI.Config)
local States = require(UI.States)
local Sift = require(Packages.Sift)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Category = require(script.Parent.Category)

export type Props = Category.Props & {}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Category(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Label = { "Credits" },
		HorizontalAlignment = Enum.HorizontalAlignment.Center,

		[Children] = {
			Scope:ForValues(CONFIG.Credits.Contributors, function(Use, Scope, UserGroup)
				return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
					return PanelsStateMod.Panel:is(Panel):during(function()
						local UserInfos = Scope:Value({})

						local function UpdateUserInfos()
							UserInfos:set(UserInformant.Users(UserGroup.UserIds))
						end

						task.spawn(function()
							UpdateUserInfos()
						end)

						return Scope:CreditGroup {
							Title = UserGroup.Name,
							Credits = Scope:Computed(function(Use)
								return Sift.Array.map(Use(UserInfos), function(UserInfo: UserInformant.UserInfo)
									return {
										Label = UserInfo.Username,
										Image = `rbxthumb://type=AvatarHeadShot&id={UserInfo.UserId}&w=48&h=48`,
										Link = `https://roblox.com/users/{UserInfo.UserId}/profile`,
									}
								end)
							end),
						}
					end)
				end)
			end),
		},
	}))
end
