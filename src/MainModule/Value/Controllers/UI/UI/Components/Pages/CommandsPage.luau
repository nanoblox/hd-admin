local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Parent.Parent.Packages.Sift)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Setting = require(script.Parent.Parent.Setting)
local CommandButton = require(script.Parent.Parent.CommandButton)
local CommandCategory = require(script.Parent.Parent.CommandCategory)
local IconToggle = require(script.Parent.Parent.IconToggle)
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

	local SearchQuery = Scope:Value("")
	local RankTags = Scope:Value({})

	local FilteredCommands = Scope:Computed(function(Use)
		local SearchQueryValue = Use(SearchQuery)
		local RankTagsValue = Use(RankTags)

		return Sift.Dictionary.filter(CONFIG.Commands, function(Command)
			if #RankTagsValue >= 1 then
				if table.find(Sift.Array.flatten(RankTagsValue), Command.Rank) == nil then
					return false
				end
			end
			if utf8.len(SearchQueryValue) >= 1 then
				if string.find(Command.Prompt, SearchQueryValue) == nil then
					return false
				end
			end

			return true
		end)
	end)
	local FilteredCategories = Scope:Computed(function(Use)
		local FilteredCommandsValue = Use(FilteredCommands)

		return Sift.Array.sort(
			Sift.Array.filter(
				Sift.Array.map(CONFIG.Roles, function(Role)
					return {
						Label = { Role },
						Role = Role,
						Commands = Sift.Dictionary.keys(Sift.Dictionary.filter(FilteredCommandsValue, function(Command)
							return Command.Rank == Role
						end)),
					}
				end),
				function(Category)
					return #Category.Commands > 0
				end
			),
			function(Category1, Category2)
				return table.find(CONFIG.Roles, Category1.Role) < table.find(CONFIG.Roles, Category2.Role)
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
								Toggled = States.Menu.Pages.Commands.QuickRun,
								ContentSize = Theme.TextSize["1.125"],
								Aspect = {
									Ratio = 1,
									Type = Enum.AspectType.ScaleWithParentSize,
								},
							},
						},
					},
					Scope:Scroller {
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

						[Children] = {
							Scope:Tags {
								Tags = Sift.Array.map(CONFIG.Roles, function(RankString: string)
									return { RankString }
								end),
								Selection = RankTags,
								ButtonProps = {
									SizeVariant = "Large",
									ContentSize = Theme.TextSize["1"],
								},
							},
						},
					},
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
								return Scope:CommandCategory {
									Label = Category.Label,
									Commands = Category.Commands,
								}
							end)
						end),
					},
				},
			},
		},
	}))
end
