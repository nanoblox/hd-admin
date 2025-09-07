local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local UserInformant = require(HDAdminUI.Utils.UserInformant)
local Config = require(HDAdminUI.Config)
local States = require(HDAdminUI.States)
local Sift = require(HDAdminUI.Parent.Sift)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Category = require(script.Parent.Category)

export type Props = Category.Props & {}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Category(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Label = { "Libraries" },
		HorizontalAlignment = Enum.HorizontalAlignment.Center,

		[Children] = {
			Scope:CreditGroup {
				Title = nil,
				Credits = Scope:Computed(function(Use)
					return Sift.Array.map(CONFIG.Credits.Libraries, function(Library)
						return {
							Label = Library.Name,
							Image = Library.Image,
							Link = Library.Link,
						}
					end)
				end),
			},
		},
	}))
end
