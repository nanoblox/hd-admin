local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Config = require(UI.Config)
local Sift = require(Packages.Sift)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local Future = require(Packages.Future)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Setting = require(script.Parent.Parent.Setting)
local CommandButton = require(script.Parent.Parent.CommandButton)
local CommandCategory = require(script.Parent.Parent.CommandCategory)
local IconToggle = require(script.Parent.Parent.IconToggle)
local Callbacks = require(script.Parent.Parent.Parent.Callbacks)
local Tags = require(script.Parent.Parent.Tags)

export type Props = OnyxUI.FrameProps & {
	Open: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Setting = Setting,
		CommandButton = CommandButton,
		CommandCategory = CommandCategory,
		IconToggle = IconToggle,
		Tags = Tags,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local SearchQuery = Scope:Value("")
	local RoleTags = Panel.PagesData.Commands.ActiveTags
	local CategoryTags = Scope:Value({})

	local FilteredCommands = Scope:Computed(function(Use)
		local SearchQueryValue = Use(SearchQuery)
		local RoleTagsValue = Use(RoleTags)
		local CategoryTagsValue = Use(CategoryTags)

		return Sift.Dictionary.filter(CONFIG.Commands, function(Command)
			if #RoleTagsValue >= 1 then
				if
					Sift.Array.some(Sift.Array.flatten(RoleTagsValue), function(RoleId)
						return Sift.Array.includes(Command.Roles, RoleId)
					end) == false
				then
					return false
				end
			end

			if #CategoryTagsValue >= 1 then
				if
					Sift.Array.some(Sift.Array.flatten(CategoryTagsValue), function(Category: string)
						return Command.Category == Category
					end) == false
				then
					return false
				end
			end

			if utf8.len(SearchQueryValue) >= 1 then
				if string.find(Command.Name, SearchQueryValue) == nil then
					return false
				end
			end

			return true
		end)
	end)
	local FilteredCategories = Scope:Computed(function(Use)
		local FilteredCommandsValue = Use(FilteredCommands)

		return Sift.Array.sort(
			Sift.Dictionary.values(Sift.Dictionary.filter(
				Sift.Dictionary.map(CONFIG.Roles, function(Role, Id)
					return {
						Label = { Role.Name },
						Role = Id,
						Commands = Sift.Dictionary.keys(Sift.Dictionary.filter(FilteredCommandsValue, function(Command)
							return table.find(Command.Roles, Id) ~= nil
						end)),
					},
						Id
				end),
				function(Category)
					return #Category.Commands > 0
				end
			)),
			function(Category1, Category2)
				return CONFIG.Roles[Category1.Role].Level < CONFIG.Roles[Category2.Role].Level
			end
		)
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Frame {
				List = {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Wraps = false,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:Frame {
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							VerticalAlignment = Enum.VerticalAlignment.Center,
							VerticalFlex = Enum.UIFlexAlignment.Fill,
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
							Scope:IconToggle {
								Name = "CommandBarToggle",
								Options = { CONFIG.Icons.Terminal, CONFIG.Icons.TerminalFill },
								Toggled = States.CommandBar.Open,
								ContentSize = Theme.TextSize["1.125"],
								Aspect = {
									Ratio = 1,
									Type = Enum.AspectType.ScaleWithParentSize,
								},
							},
							Scope:IconToggle {
								Name = "QuickRunToggle",
								Options = { CONFIG.Icons.Zap, CONFIG.Icons.ZapFill },
								Toggled = Panel.PagesData.Commands.QuickRun,
								ContentSize = Theme.TextSize["1.125"],
								Aspect = {
									Ratio = 1,
									Type = Enum.AspectType.ScaleWithParentSize,
								},
							},
						},
					},
					Scope:Computed(function(Use)
						local TagsLocked = Use(Panel.PagesData.Commands.TagsLocked)

						if not TagsLocked then
							return OnyxUI.Themer.Theme:is(Theme):during(function()
								return Scope:Scroller {
									Name = "Tags",
									ScrollingDirection = Enum.ScrollingDirection.X,
									ScrollBarThickness = 0,
									ScrollBarImageTransparency = 1,
									CanvasSize = UDim2.fromOffset(0, 0),
									AutomaticCanvasSize = Enum.AutomaticSize.X,
									AutomaticSize = Enum.AutomaticSize.Y,
									Padding = {
										All = Scope:UDim(0, Theme.StrokeThickness["1"]),
									},
									List = {
										FillDirection = Enum.FillDirection.Horizontal,
										Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
									},

									[Children] = {
										Scope:Tags {
											Tags = Sift.Array.map(
												Sift.Array.sort(
													Sift.Dictionary.values(CONFIG.Roles),
													function(RoleA, RoleB)
														return RoleA.Level < RoleB.Level
													end
												),
												function(Role)
													local Icon = CONFIG.Icons.PersonTagFill

													if Role.Gamepass ~= nil then
														Icon = CONFIG.Icons.RobuxFill
													end

													return { Role.Name, Icon }
												end
											),
											Selection = RoleTags,
											ButtonProps = {
												SizeVariant = "Large",
												ContentSize = Theme.TextSize["1"],
											},

											OnSelect = function(TagContent, Enabled)
												if not Enabled then
													return
												end

												local MatchingRole = nil

												for Id, Role in CONFIG.Roles do
													if Id == TagContent[1] then
														MatchingRole = Role
													end
												end

												if MatchingRole and (MatchingRole.Gamepass ~= nil) then
													Future.Try(function()
														return Callbacks.PurchaseRoleGamepass(MatchingRole.Gamepass)
													end)
												end
											end,
										},
										Scope:Tags {
											Tags = Sift.Array.map(CONFIG.CommandCategories, function(Category)
												return { Category, CONFIG.Icons.TagFill }
											end),
											Selection = CategoryTags,
											ButtonProps = {
												SizeVariant = "Large",
												ContentSize = Theme.TextSize["1"],
											},
										},
									},
								}
							end)
						end
					end),
				},
			},
			Scope:Scroller {
				Name = "Commands",
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["1.5"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					[Children] = {
						Scope:ForValues(FilteredCategories, function(Use, Scope, Category)
							return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
								return PanelsStateMod.Panel:is(Panel):during(function()
									return Scope:CommandCategory {
										Label = Category.Label,
										Commands = Category.Commands,
									}
								end)
							end)
						end),
					},
				},
			},
		},
	}))
end
