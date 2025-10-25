local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Pages = require(UI.Static.Pages)
local Config = require(UI.Config)
local Sift = require(Packages.Sift)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local PageButton = require(script.Parent.Parent.PageButton)
local TitleBar2 = require(script.Parent.Parent.TitleBar2)

local PAGES = {
	Dashboard = require(script.Parent.Parent.Pages.DashboardPage),
	Commands = require(script.Parent.Parent.Pages.CommandsPage),
	About = require(script.Parent.Parent.Pages.AboutPage),
	Placeholder = require(script.Parent.Parent.Pages.PlaceholderPage),
	Settings = require(script.Parent.Parent.Pages.SettingsPage),
	Execute = require(script.Parent.Parent.Pages.ExecutePage),
	Moderation = require(script.Parent.Parent.Pages.ModerationPage),
	User = require(script.Parent.Parent.Pages.UserPage),
	Users = require(script.Parent.Parent.Pages.UsersPage),
	Cosmetics = require(script.Parent.Parent.Pages.CosmeticsPage),
	Booster = require(script.Parent.Parent.Pages.BoosterPage),
	Roles = require(script.Parent.Parent.Pages.RolesPage),
}

export type Props = OnyxUI.AutoScalerProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, {
		PageButton = PageButton,
		TitleBar2 = TitleBar2,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local Page = Scope:Computed(function(Use)
		return Pages[Use(Panel.Page)]
	end)
	local PageHistory = Scope:Computed(function(Use)
		local UndoHistoryValue = Use(Panel.PageUndoHistory)
		local HistoryValue = Use(Panel.PageHistory)

		return Sift.Array.merge(UndoHistoryValue, HistoryValue)
	end)
	local RenderedPages = Scope:Computed(function(Use)
		local PageValue = Use(Panel.Page)
		local PageHistoryValue = Use(Panel.PageHistory)
		local PageUndoHistoryValue = Use(Panel.PageUndoHistory)

		local ValidValues = {
			PageValue,
			PageHistoryValue[#PageHistoryValue - 1],
			PageUndoHistoryValue[#PageUndoHistoryValue - 1],
		}

		return Sift.Dictionary.keys(Sift.Dictionary.filter(PAGES, function(_, Name)
			return table.find(ValidValues, Name) ~= nil
		end))
	end)

	local LastPageHistory = Scope:Value({})
	local LastPageHistoryRaw = {}
	Scope:Observer(PageHistory):onChange(function()
		local PageHistoryValue = Fusion.peek(PageHistory)

		LastPageHistory:set(LastPageHistoryRaw)

		LastPageHistoryRaw = PageHistoryValue
	end)

	local Enabled = Scope:Value(true)

	local OpenCloseThread = nil

	local function TransitionOpenClose()
		if OpenCloseThread ~= nil then
			task.cancel(OpenCloseThread)
		end

		local OpenValue = Fusion.peek(Panel.Open)

		Enabled:set(OpenValue)
	end

	Scope:Observer(Panel.Open):onChange(function()
		TransitionOpenClose()
	end)
	TransitionOpenClose()

	return Scope:AutoScaler(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		BaseResolution = Vector2.new(700, 500),
		MaxScale = 1,
		MinScale = 0.6,
		Visible = Enabled,

		[Children] = {
			Scope:Group {
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(Use(Theme.Sizing["1"]) * 20, 0)
				end),
				BackgroundColor3 = Theme.Colors.Base.Main,
				BackgroundTransparency = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				GroupTransparency = Scope:Spring(
					Scope:Computed(function(Use)
						return Use(Panel.Open) and 0 or 1
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1.5"]
				),
				Padding = {
					All = Scope:UDim(0, Theme.Padding["0"]),
				},
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Stroke = {
					Transparency = 0.5,
				},
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius["2"]),
				},

				[Children] = {
					Scope:TitleBar2 {
						Content = Scope:Computed(function(Use)
							local PageValue = Use(Page)
							local PageIdValue = Use(Panel.Page)
							local TitleValue = Use(Panel.Title)

							if TitleValue ~= nil then
								return { TitleValue }
							elseif PageIdValue == "Dashboard" then
								return { CONFIG.Icons.LogoGlyph, PageValue.Name or PageValue.Id or PageIdValue }
							else
								return { PageValue.Name or PageValue.Id or PageIdValue }
							end
						end),

						OnDrag = function(DeltaPosition: Vector2)
							local MenuPositionValue = Fusion.peek(Panel.Position)
							local ScreenResolutionValue = Fusion.peek(States.Screen.Resolution)

							MenuPositionValue += (DeltaPosition / ScreenResolutionValue)

							Panel.Position:set(MenuPositionValue)
						end,
					},
					Scope:Frame {
						Size = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(Panel.Open) then
									return UDim2.fromOffset(0, Use(Theme.Sizing["24"]))
								else
									return UDim2.fromOffset(0, 0)
								end
							end),
							Theme.SpringSpeed["2"],
							Theme.SpringDampening["1.5"]
						),
						AutomaticSize = Enum.AutomaticSize.X,
						ClipsDescendants = true,
						Padding = {
							All = Scope:UDim(0, Theme.Padding["1"]),
						},
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = Scope:UDim(0, Theme.Spacing["0"]),
						},

						[Children] = {
							Scope:ForPairs(PAGES, function(Use, Scope, Name, Component)
								return Name,
									OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
										return PanelsStateMod.Panel:is(Panel):during(function()
											local HistoryIndex = Scope:Computed(function(Use)
												local LastPageHistoryValue = Use(LastPageHistory)

												return table.find(LastPageHistoryValue, Name) or 0
											end)
											local Open = Scope:Computed(function(Use)
												local PageValue = Use(Panel.Page)

												if PageValue == Name then
													return true
												elseif (PAGES[PageValue] == nil) and (Name == "Placeholder") then
													return true
												else
													return false
												end
											end)
											local Rendered = Scope:Computed(function(Use)
												local RenderedPagesValue = Use(RenderedPages)

												return table.find(RenderedPagesValue, Name) ~= nil
											end)

											return Scope:Frame {
												Name = Name,
												Size = Scope:Spring(
													Scope:Computed(function(Use)
														local OpenValue = Use(Open)

														if OpenValue then
															return UDim2.fromScale(1, 1)
														else
															return UDim2.fromScale(0, 1)
														end
													end),
													Theme.SpringSpeed["2"],
													Theme.SpringDampening["1.5"]
												),
												AutomaticSize = Enum.AutomaticSize.Y,
												LayoutOrder = HistoryIndex,
												ClipsDescendants = true,
												List = {
													VerticalFlex = Enum.UIFlexAlignment.Fill,
												},

												[Children] = {
													Scope:Computed(function(Use)
														local RenderedValue = Use(Rendered)

														if RenderedValue then
															return OnyxUI.Themer.Theme:is(Theme):during(function()
																return PanelsStateMod.Panel:is(Panel):during(function()
																	return Component(Scope, {
																		Name = Name,
																		Open = true,
																		Size = Scope:UDim2Offset(288, 0),
																		AutomaticSize = Enum.AutomaticSize.None,
																		Padding = {
																			All = Scope:UDim(
																				0,
																				Theme.StrokeThickness["1"]
																			),
																		},
																	})
																end)
															end)
														end
													end),
												},
											}
										end)
									end)
							end),
						},
					},
				},
			},
		},
	}))
end
