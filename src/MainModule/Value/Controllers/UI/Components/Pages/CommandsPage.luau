local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Sift)

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

	local SearchCommands = Scope:ForPairs(CONFIG.Commands, function(Use, Scope, CommandId: string, Command)
		local SearchQueryValue = Use(SearchQuery)

		if Command and (string.match(Command.Prompt, SearchQueryValue) ~= nil) then
			return CommandId, Command
		end
	end)
	local RankCategories = Scope:ForValues(CONFIG.Roles, function(Use, Scope, Rank: string)
		local RankTagsValue = Use(RankTags)
		local RankTagIds = Sift.Array.map(RankTagsValue, function(RankTag: { string })
			return RankTag[1]
		end)
		local RankCommands = Sift.Dictionary.keys(Sift.Dictionary.filter(CONFIG.Commands, function(Command)
			return Command.Rank == Rank
		end))

		if #RankCommands == 0 then
			return
		end
		if (#RankTagIds >= 1) and (table.find(RankTagIds, Rank) == nil) then
			return
		end

		return {
			Label = { Rank },
			Commands = RankCommands,
		}
	end)
	local ActiveCategories = Scope:Computed(function(Use)
		local SearchQueryValue = Use(SearchQuery)
		local SearchCommandsValue = Use(SearchCommands)
		local RankCategoriesValue = Use(RankCategories)

		if utf8.len(SearchQueryValue) >= 1 then
			return {
				{
					Commands = Sift.Dictionary.keys(SearchCommandsValue),
				},
			}
		else
			return RankCategoriesValue
		end
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Frame {
				Name = "Options",
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
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
						Scope:ForValues(ActiveCategories, function(Use, Scope, Category)
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
