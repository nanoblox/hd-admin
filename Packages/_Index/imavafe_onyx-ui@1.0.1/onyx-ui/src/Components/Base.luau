--[=[
		@class Base

		The foundational component of OnyxUI, from which all other components are built off of. Props supported here typically work in all other components.
]=]

--[=[
	@interface GradientProps
	@within Base

	.Enabled boolean? -- Whether the gradient is enabled.
	.Color ColorSequence? -- The color sequence of the gradient.
	.Offset UDim? -- The offset of the gradient.
	.Rotation number? -- The rotation of the gradient.
	.Transparency NumberSequence? -- The transparency sequence of the gradient.
]=]

--[=[
	@interface PaddingProps
	@within Base

	.Enabled boolean? -- Whether the padding is enabled.
	.All UDim? -- The padding applied to all sides.
	.Top UDim? -- The padding applied to the top side.
	.Left UDim? -- The padding applied to the left side.
	.Right UDim? -- The padding applied to the right side.
	.Bottom UDim? -- The padding applied to the bottom side.
]=]

--[=[
	@interface CornerProps
	@within Base

	.Enabled boolean? -- Whether the corner is enabled.
	.Radius UDim? -- The radius of the corner.
]=]

--[=[
	@interface StrokeProps
	@within Base

	.Enabled boolean? -- Whether the stroke is enabled.
	.Thickness number? -- The thickness of the stroke.
	.Color Color3? -- The color of the stroke.
	.Transparency number? -- The transparency of the stroke.
	.LineJoinMode Enum.LineJoinMode? -- The line join mode of the stroke.
	.ApplyStrokeMode Enum.ApplyStrokeMode? -- The apply stroke mode of the stroke.
	.Gradient GradientProps? -- The gradient applied to the stroke.
]=]

--[=[
	@interface AspectProps
	@within Base

	.Enabled boolean? -- Whether the aspect ratio constraint is enabled.
	.Ratio number? -- The aspect ratio.
	.Type Enum.AspectType? -- The aspect type.
	.DominantAxis Enum.DominantAxis? -- The dominant axis.
]=]

--[=[
	@interface ScaleProps
	@within Base

	.Enabled boolean? -- Whether the scale is enabled.
	.Scale number? -- The scale factor.
]=]

--[=[
	@interface FlexProps
	@within Base

	.Enabled boolean? -- Whether the flex item is enabled.
	.Mode Enum.UIFlexMode? -- The flex mode.
	.ItemLineAlignment Enum.ItemLineAlignment? -- The alignment of items along the line.
	.GrowRatio number? -- The grow ratio of the flex item.
	.ShrinkRatio number? -- The shrink ratio of the flex item.
]=]

--[=[
	@interface ListProps
	@within Base

	.Enabled boolean? -- Whether the list layout is enabled.
	.Padding UDim? -- The padding between items in the list.
	.FillDirection Enum.FillDirection? -- The fill direction of the list.
	.SortOrder Enum.SortOrder? -- The sort order of the list.
	.Wraps boolean? -- Whether the list wraps.
	.HorizontalAlignment Enum.HorizontalAlignment? -- The horizontal alignment of the list.
	.HorizontalFlex boolean? -- Whether horizontal flex is enabled.
	.VerticalAlignment Enum.VerticalAlignment? -- The vertical alignment of the list.
	.VerticalFlex boolean? -- Whether vertical flex is enabled.
	.ItemLineAlignment Enum.ItemLineAlignment? -- The alignment of items along the line.
]=]

--[=[
	@interface GridProps
	@within Base

	.Enabled boolean? -- Whether the grid layout is enabled.
	.CellPadding UDim2? -- The padding between cells in the grid.
	.CellSize UDim2? -- The size of each cell in the grid.
	.FillDirection Enum.FillDirection? -- The fill direction of the grid.
	.FillDirectionMaxCells number? -- The maximum number of cells in the fill direction.
	.SortOrder Enum.SortOrder? -- The sort order of the grid.
	.StartCorner Enum.StartCorner? -- The starting corner of the grid.
	.HorizontalAlignment Enum.HorizontalAlignment? -- The horizontal alignment of the grid.
	.VerticalAlignment Enum.VerticalAlignment? -- The vertical alignment of the grid.
]=]

--[=[
	@interface TableProps
	@within Base

	.Enabled boolean? -- Whether the table layout is enabled.
	.Padding UDim? -- The padding between items in the table.
	.FillEmptySpaceColumns boolean? -- Whether empty space in columns is filled.
	.FillEmptySpaceRows boolean? -- Whether empty space in rows is filled.
	.FillDirection Enum.FillDirection? -- The fill direction of the table.
	.SortOrder Enum.SortOrder? -- The sort order of the table.
	.MajorAxis Enum.TableMajorAxis? -- The major axis of the table.
	.HorizontalAlignment Enum.HorizontalAlignment? -- The horizontal alignment of the table.
	.VerticalAlignment Enum.VerticalAlignment? -- The vertical alignment of the table.
]=]

--[=[
	@interface PageProps
	@within Base

	.Enabled boolean? -- Whether the page layout is enabled.
	.Animated boolean? -- Whether the page transitions are animated.
	.Circular boolean? -- Whether the pages are circular.
	.EasingDirection Enum.EasingDirection? -- The easing direction for transitions.
	.EasingStyle Enum.EasingStyle? -- The easing style for transitions.
	.Padding UDim? -- The padding between pages.
	.TweenTime number? -- The time for page transitions.
	.FillDirection Enum.FillDirection? -- The fill direction of the pages.
	.SortOrder Enum.SortOrder? -- The sort order of the pages.
	.HorizontalAlignment Enum.HorizontalAlignment? -- The horizontal alignment of the pages.
	.VerticalAlignment Enum.VerticalAlignment? -- The vertical alignment of the pages.
	.GamepadInputEnabled boolean? -- Whether gamepad input is enabled.
	.ScrollWheelInputEnabled boolean? -- Whether scroll wheel input is enabled.
	.TouchInputEnabled boolean? -- Whether touch input is enabled.
]=]

--[=[
	@interface SizeLimitProps
	@within Base

	.Enabled boolean? -- Whether the size constraint is enabled.
	.Max Vector2? -- The maximum size.
	.Min Vector2? -- The minimum size.
]=]

--[=[
	@interface TextSizeLimitProps
	@within Base

	.Enabled boolean? -- Whether the text size constraint is enabled.
	.Max number? -- The maximum text size.
	.Min number? -- The minimum text size.
]=]

--[=[
	@interface BaseProps
	@within Base

	.ClassName string? -- The class name of the component.
	.Name string? -- The name of the component.
	.Parent Instance? -- The parent instance of the component.
	.Position UDim2? -- The position of the component.
	.Rotation number? -- The rotation of the component.
	.AnchorPoint Vector2? -- The anchor point of the component.
	.Size UDim2? -- The size of the component.
	.AutomaticSize Enum.AutomaticSize? -- The automatic size of the component.
	.Visible boolean? -- Whether the component is visible.
	.ZIndex number? -- The ZIndex of the component.
	.LayoutOrder number? -- The layout order of the component.
	.ClipsDescendants boolean? -- Whether the component clips its descendants.
	.Active boolean? -- Whether the component is active.
	.Selectable boolean? -- Whether the component is selectable.
	.Interactable boolean? -- Whether the component is interactable.
	.BackgroundColor3 Color3? -- The background color of the component.
	.BackgroundTransparency number? -- The background transparency of the component.
	.NextSelectionDown GuiObject? -- The next selection down.
	.NextSelectionUp GuiObject? -- The next selection up.
	.NextSelectionRight GuiObject? -- The next selection right.
	.NextSelectionLeft GuiObject? -- The next selection left.
	.SelectionImageObject GuiObject? -- The selection image object.
	.SelectionOrder number? -- The selection order.
	.SizeConstraint Enum.SizeConstraint? -- The size constraint of the component.
	.AutoLocalize boolean? -- Whether the component auto-localizes.
	.RootLocalizationTable LocalizationTable? -- The root localization table.
	.SelectionBehaviorDown Enum.SelectionBehavior? -- The selection behavior down.
	.SelectionBehaviorUp Enum.SelectionBehavior? -- The selection behavior up.
	.SelectionBehaviorRight Enum.SelectionBehavior? -- The selection behavior right.
	.SelectionBehaviorLeft Enum.SelectionBehavior? -- The selection behavior left.
	.SelectionGroup boolean? -- Whether the component is part of a selection group.

	.Corner CornerProps? -- The corner properties.
	.Padding PaddingProps? -- The padding properties.
	.Stroke StrokeProps? -- The stroke properties.
	.Gradient GradientProps? -- The gradient properties.
	.Aspect AspectProps? -- The aspect ratio properties.
	.Scale ScaleProps? -- The scale properties.

	.List ListProps? -- The list layout properties.
	.Grid GridProps? -- The grid layout properties.
	.Table TableProps? -- The table layout properties.
	.Page PageProps? -- The page layout properties.

	.Flex FlexProps? -- The flex layout properties.
	.SizeLimit SizeLimitProps? -- The size limit properties.
	.TextSizeLimit TextSizeLimitProps? -- The text size limit properties.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

export type GradientProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Color: Fusion.UsedAs<ColorSequence>?,
	Offset: Fusion.UsedAs<UDim>?,
	Rotation: Fusion.UsedAs<number>?,
	Transparency: Fusion.UsedAs<NumberSequence>?,
}
export type PaddingProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	All: Fusion.UsedAs<UDim>?,
	Top: Fusion.UsedAs<UDim>?,
	Left: Fusion.UsedAs<UDim>?,
	Right: Fusion.UsedAs<UDim>?,
	Bottom: Fusion.UsedAs<UDim>?,
}
export type CornerProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Radius: Fusion.UsedAs<UDim>?,
}
export type StrokeProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Thickness: Fusion.UsedAs<number>?,
	Color: Fusion.UsedAs<Color3>?,
	Transparency: Fusion.UsedAs<number>?,
	LineJoinMode: Fusion.UsedAs<Enum.LineJoinMode>?,
	ApplyStrokeMode: Fusion.UsedAs<Enum.ApplyStrokeMode>?,

	Gradient: Fusion.UsedAs<GradientProps>?,
}
export type AspectProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Ratio: Fusion.UsedAs<number>?,
	Type: Fusion.UsedAs<Enum.AspectType>?,
	DominantAxis: Fusion.UsedAs<Enum.DominantAxis>?,
}
export type ScaleProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Scale: Fusion.UsedAs<number>?,
}
export type FlexProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Mode: Fusion.UsedAs<Enum.UIFlexMode>?,
	ItemLineAlignment: Fusion.UsedAs<Enum.ItemLineAlignment>?,
	GrowRatio: Fusion.UsedAs<number>?,
	ShrinkRatio: Fusion.UsedAs<number>?,
}
export type ListProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Padding: Fusion.UsedAs<UDim>?,
	FillDirection: Fusion.UsedAs<Enum.FillDirection>?,
	SortOrder: Fusion.UsedAs<Enum.SortOrder>?,
	Wraps: Fusion.UsedAs<boolean>?,
	HorizontalAlignment: Fusion.UsedAs<Enum.HorizontalAlignment>?,
	HorizontalFlex: Fusion.UsedAs<boolean>?,
	VerticalAlignment: Fusion.UsedAs<Enum.VerticalAlignment>?,
	VerticalFlex: Fusion.UsedAs<boolean>?,
	ItemLineAlignment: Fusion.UsedAs<Enum.ItemLineAlignment>?,
}
export type GridProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	CellPadding: Fusion.UsedAs<UDim>?,
	CellSize: Fusion.UsedAs<UDim2>?,
	FillDirection: Fusion.UsedAs<Enum.FillDirection>?,
	FillDirectionMaxCells: Fusion.UsedAs<number>?,
	SortOrder: Fusion.UsedAs<Enum.SortOrder>?,
	StartCorner: Fusion.UsedAs<Enum.StartCorner>?,
	HorizontalAlignment: Fusion.UsedAs<Enum.HorizontalAlignment>?,
	VerticalAlignment: Fusion.UsedAs<Enum.VerticalAlignment>?,
}
export type TableProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Padding: Fusion.UsedAs<UDim>?,
	FillEmptySpaceColumns: Fusion.UsedAs<boolean>?,
	FillEmptySpaceRows: Fusion.UsedAs<boolean>?,
	FillDirection: Fusion.UsedAs<Enum.FillDirection>?,
	SortOrder: Fusion.UsedAs<Enum.SortOrder>?,
	MajorAxis: Fusion.UsedAs<Enum.TableMajorAxis>?,
	HorizontalAlignment: Fusion.UsedAs<Enum.HorizontalAlignment>?,
	VerticalAlignment: Fusion.UsedAs<Enum.VerticalAlignment>?,
}
export type PageProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Animated: Fusion.UsedAs<boolean>?,
	Circular: Fusion.UsedAs<boolean>?,
	EasingDirection: Fusion.UsedAs<Enum.EasingDirection>?,
	EasingStyle: Fusion.UsedAs<Enum.EasingStyle>?,
	Padding: Fusion.UsedAs<UDim>?,
	TweenTime: Fusion.UsedAs<number>?,
	FillDirection: Fusion.UsedAs<Enum.FillDirection>?,
	SortOrder: Fusion.UsedAs<Enum.SortOrder>?,
	HorizontalAlignment: Fusion.UsedAs<Enum.HorizontalAlignment>?,
	VerticalAlignment: Fusion.UsedAs<Enum.VerticalAlignment>?,
	GamepadInputEnabled: Fusion.UsedAs<boolean>?,
	ScrollWheelInputEnabled: Fusion.UsedAs<boolean>?,
	TouchInputEnabled: Fusion.UsedAs<boolean>?,
}
export type SizeLimitProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Max: Fusion.UsedAs<Vector2>?,
	Min: Fusion.UsedAs<Vector2>?,
}
export type TextSizeLimitProps = {
	Enabled: Fusion.UsedAs<boolean>?,
	Max: Fusion.UsedAs<number>?,
	Min: Fusion.UsedAs<number>?,
}
export type Props = {
	ClassName: string?,

	Name: Fusion.UsedAs<string>?,
	Parent: Fusion.UsedAs<Instance>?,
	Position: Fusion.UsedAs<UDim2>?,
	Rotation: Fusion.UsedAs<number>?,
	AnchorPoint: Fusion.UsedAs<Vector2>?,
	Size: Fusion.UsedAs<UDim2>?,
	AutomaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
	Visible: Fusion.UsedAs<boolean>?,
	ZIndex: Fusion.UsedAs<number>?,
	LayoutOrder: Fusion.UsedAs<number>?,
	ClipsDescendants: Fusion.UsedAs<boolean>?,
	Active: Fusion.UsedAs<boolean>?,
	Selectable: Fusion.UsedAs<boolean>?,
	Interactable: Fusion.UsedAs<boolean>?,
	BackgroundColor3: Fusion.UsedAs<Color3>?,
	BackgroundTransparency: Fusion.UsedAs<number>?,
	NextSelectionDown: Fusion.UsedAs<GuiObject>?,
	NextSelectionUp: Fusion.UsedAs<GuiObject>?,
	NextSelectionRight: Fusion.UsedAs<GuiObject>?,
	NextSelectionLeft: Fusion.UsedAs<GuiObject>?,
	SelectionImageObject: Fusion.UsedAs<GuiObject>?,
	SelectionOrder: Fusion.UsedAs<number>?,
	SizeConstraint: Fusion.UsedAs<Enum.SizeConstraint>?,
	AutoLocalize: Fusion.UsedAs<boolean>?,
	RootLocalizationTable: Fusion.UsedAs<LocalizationTable>?,
	SelectionBehaviorDown: Fusion.UsedAs<Enum.SelectionBehavior>?,
	SelectionBehaviorUp: Fusion.UsedAs<Enum.SelectionBehavior>?,
	SelectionBehaviorRight: Fusion.UsedAs<Enum.SelectionBehavior>?,
	SelectionBehaviorLeft: Fusion.UsedAs<Enum.SelectionBehavior>?,
	SelectionGroup: Fusion.UsedAs<boolean>?,

	Corner: CornerProps?,
	Padding: PaddingProps?,
	Stroke: StrokeProps?,
	Gradient: GradientProps?,
	Aspect: AspectProps?,
	Scale: ScaleProps?,

	List: ListProps?,
	Grid: GridProps?,
	Table: TableProps?,
	Page: PageProps?,
	Flex: FlexProps?,

	SizeLimit: SizeLimitProps?,
	TextSizeLimit: TextSizeLimitProps?,
}

return function(Scope: Fusion.Scope<any>, Props: Props): Instance
	local Scope = Fusion.innerScope(Scope, Fusion, Util)
	local Theme = Themer.Theme:now()

	local ClassName = Util.Fallback(Props.ClassName, "Frame")
	local Name = Util.Fallback(Props.Name, "Base")
	local AutomaticSize = Util.Fallback(Props.AutomaticSize, Enum.AutomaticSize.XY)
	local BackgroundColor3 = Util.Fallback(Props.BackgroundColor3, Theme.Colors.Base.Main)
	local Corner = Util.Fallback(Props.Corner, {
		Radius = Scope:UDim(Scope, 0, Theme.CornerRadius["1"]),
	})
	local Stroke = Util.Fallback(Props.Stroke, {
		Thickness = Theme.StrokeThickness["1"],
		Color = Scope:Computed(function(Use)
			return Util.Emphasize(Use(BackgroundColor3), Use(Theme.StrokeEmphasis["Regular"]))
		end),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Scope:Computed(function(Use)
			local CornerRadiusValue = Use(Use(Corner).Radius)

			if (CornerRadiusValue ~= nil) and ((CornerRadiusValue.Offset > 1) or (CornerRadiusValue.Scale > 1)) then
				return Enum.LineJoinMode.Round
			else
				return Enum.LineJoinMode.Miter
			end
		end),
	})
	local Padding = Util.Fallback(Props.Padding, {
		All = Scope:UDim(0, Theme.Padding["1"]),
	})
	local List = Util.Fallback(Props.List, {
		Padding = Scope:UDim(0, Theme.Padding["1"]),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local Grid = Util.Fallback(Props.Grid, {
		CellPadding = Scope:UDim2Offset(Theme.Padding["1"], Theme.Padding["1"]),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local Table = Util.Fallback(Props.Table, {
		Padding = Scope:UDim2Offset(Theme.Padding["1"], Theme.Padding["1"]),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local Page = Util.Fallback(Props.Page, {
		Padding = Scope:UDim(0, Theme.Padding["1"]),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local PaddingActive = Scope:Computed(function(Use)
		local InProps = Use(Props.Padding) ~= nil
		local PaddingValue = Use(Padding) or {}
		local Paddings =
			{ PaddingValue.All, PaddingValue.Top, PaddingValue.Left, PaddingValue.Right, PaddingValue.Bottom }

		if InProps then
			for _, PaddingProp in Paddings do
				local PaddingPropValue = Use(PaddingProp)

				if typeof(PaddingPropValue) == "UDim" then
					return true
				end
			end
		end

		return false
	end)

	return Scope:New(ClassName) {
		Name = Name,
		AutomaticSize = AutomaticSize,

		Parent = Props.Parent,
		Position = Props.Position,
		Rotation = Props.Rotation,
		AnchorPoint = Props.AnchorPoint,
		Size = Props.Size,
		Visible = Props.Visible,
		ZIndex = Props.ZIndex,
		LayoutOrder = Props.LayoutOrder,
		ClipsDescendants = Props.ClipsDescendants,
		Active = Props.Active,
		Selectable = Props.Selectable,
		Interactable = Props.Interactable,
		BackgroundColor3 = Props.BackgroundColor3,
		BackgroundTransparency = Props.BackgroundTransparency,
		NextSelectionDown = Props.NextSelectionDown,
		NextSelectionUp = Props.NextSelectionUp,
		NextSelectionRight = Props.NextSelectionRight,
		NextSelectionLeft = Props.NextSelectionLeft,
		SelectionImageObject = Props.SelectionImageObject,
		SelectionOrder = Props.SelectionOrder,
		SizeConstraint = Props.SizeConstraint,
		AutoLocalize = Props.AutoLocalize,
		RootLocalizationTable = Props.RootLocalizationTable,
		SelectionBehaviorDown = Props.SelectionBehaviorDown,
		SelectionBehaviorUp = Props.SelectionBehaviorUp,
		SelectionBehaviorRight = Props.SelectionBehaviorRight,
		SelectionBehaviorLeft = Props.SelectionBehaviorLeft,
		SelectionGroup = Props.SelectionGroup,

		[Children] = {
			-- Styling
			Scope:Computed(function(Use)
				local CornerValue: CornerProps = Use(Corner) or {}
				local InProps = Use(Props.Corner) ~= nil

				if InProps and (Use(CornerValue.Enabled) ~= false) then
					return Scope:New "UICorner" {
						CornerRadius = CornerValue.Radius,
					}
				end
			end),
			Scope:Computed(function(Use)
				local PaddingActiveValue = Use(PaddingActive)
				local PaddingValue: PaddingProps = Use(Padding) or {}

				if PaddingActiveValue == true then
					return Scope:New "UIPadding" {
						PaddingTop = Scope:Computed(function(Use)
							local PaddingAllValue = Use(PaddingValue.All)
							local PaddingTopValue = Use(PaddingValue.Top)

							return PaddingTopValue or PaddingAllValue or UDim.new()
						end),
						PaddingBottom = Scope:Computed(function(Use)
							local PaddingAllValue = Use(PaddingValue.All)
							local PaddingBottomValue = Use(PaddingValue.Bottom)

							return PaddingBottomValue or PaddingAllValue or UDim.new()
						end),
						PaddingLeft = Scope:Computed(function(Use)
							local PaddingAllValue = Use(PaddingValue.All)
							local PaddingLeftValue = Use(PaddingValue.Left)

							return PaddingLeftValue or PaddingAllValue or UDim.new()
						end),
						PaddingRight = Scope:Computed(function(Use)
							local PaddingAllValue = Use(PaddingValue.All)
							local PaddingRightValue = Use(PaddingValue.Right)

							return PaddingRightValue or PaddingAllValue or UDim.new()
						end),
					}
				end
			end),
			Scope:Computed(function(Use)
				local StrokeValue: StrokeProps = Use(Stroke) or {}
				local InProps = Use(Props.Stroke) ~= nil

				if InProps and (Use(StrokeValue.Enabled) ~= false) then
					return Scope:New "UIStroke" {
						Enabled = StrokeValue.Enabled,
						Thickness = StrokeValue.Thickness,
						Color = StrokeValue.Color,
						Transparency = StrokeValue.Transparency,
						ApplyStrokeMode = StrokeValue.ApplyStrokeMode,
						LineJoinMode = StrokeValue.LineJoinMode,

						[Children] = {
							Scope:Computed(function(Use)
								local GradientValue: GradientProps = Use(StrokeValue.Gradient) or {}
								local GradientInProps = StrokeValue.Gradient ~= nil

								if GradientInProps and (Use(GradientValue.Enabled) ~= false) then
									return Scope:New "UIGradient" {
										Enabled = GradientValue.Enabled,
										Color = GradientValue.Color,
										Offset = GradientValue.Offset,
										Rotation = GradientValue.Rotation,
										Transparency = GradientValue.Transparency,
									}
								end
							end),
						},
					}
				end
			end),
			Scope:Computed(function(Use)
				local GradientValue: GradientProps = Use(Props.Gradient) or {}
				local InProps = Use(Props.Gradient) ~= nil

				if InProps and (Use(GradientValue.Enabled) ~= false) then
					return Scope:New "UIGradient" {
						Enabled = GradientValue.Enabled,
						Color = GradientValue.Color,
						Offset = GradientValue.Offset,
						Rotation = GradientValue.Rotation,
						Transparency = GradientValue.Transparency,
					}
				end
			end),

			-- Sizing
			Scope:Computed(function(Use)
				local ScaleValue: ScaleProps = Use(Props.Scale) or {}
				local InProps = Use(Props.Scale) ~= nil

				if InProps and (Use(ScaleValue.Enabled) ~= false) then
					return Scope:New "UIScale" {
						Scale = ScaleValue.Scale,
					}
				end
			end),
			Scope:Computed(function(Use)
				local AspectValue: AspectProps = Use(Props.Aspect) or {}
				local InProps = Use(Props.Aspect) ~= nil

				if InProps and (Use(AspectValue.Enabled) ~= false) then
					return Scope:New "UIAspectRatioConstraint" {
						AspectRatio = AspectValue.Ratio,
						DominantAxis = AspectValue.DominantAxis,
						AspectType = AspectValue.Type,
					}
				end
			end),
			Scope:Computed(function(Use)
				local SizeLimitValue: SizeLimitProps = Use(Props.SizeLimit) or {}

				if
					(Use(SizeLimitValue.Enabled) ~= false) and (Use(SizeLimitValue.Max) ~= nil)
					or (Use(SizeLimitValue.Min) ~= nil)
				then
					return Scope:New "UISizeConstraint" {
						MaxSize = SizeLimitValue.Max,
						MinSize = SizeLimitValue.Min,
					}
				end
			end),
			Scope:Computed(function(Use)
				local TextSizeLimitValue: TextSizeLimitProps = Use(Props.TextSizeLimit) or {}

				if (Use(TextSizeLimitValue.Max) ~= nil) or (Use(TextSizeLimitValue.Min) ~= nil) then
					return Scope:New "UITextSizeConstraint" {
						MaxTextSize = TextSizeLimitValue.Max,
						MinTextSize = TextSizeLimitValue.Min,
					}
				end
			end),

			-- Layout
			Scope:Computed(function(Use)
				local ListValue: ListProps = Use(List) or {}
				local InProps = Use(Props.List) ~= nil

				if InProps and (Use(ListValue.Enabled) ~= false) then
					return Scope:New "UIListLayout" {
						Padding = ListValue.Padding,
						FillDirection = ListValue.FillDirection,
						SortOrder = ListValue.SortOrder,
						Wraps = ListValue.Wraps,
						HorizontalAlignment = ListValue.HorizontalAlignment,
						HorizontalFlex = ListValue.HorizontalFlex,
						ItemLineAlignment = ListValue.ItemLineAlignment,
						VerticalAlignment = ListValue.VerticalAlignment,
						VerticalFlex = ListValue.VerticalFlex,
					}
				end
			end),
			Scope:Computed(function(Use)
				local GridValue = Use(Grid) or {}
				local InProps = Use(Props.Grid) ~= nil

				if InProps and (Use(GridValue.Enabled) ~= false) then
					return Scope:New "UIGridLayout" {
						CellPadding = GridValue.CellPadding,
						CellSize = GridValue.CellSize,
						FillDirection = GridValue.FillDirection,
						FillDirectionMaxCells = GridValue.FillDirectionMaxCells,
						SortOrder = GridValue.SortOrder,
						StartCorner = GridValue.StartCorner,
						HorizontalAlignment = GridValue.HorizontalAlignment,
						VerticalAlignment = GridValue.VerticalAlignment,
					}
				end
			end),
			Scope:Computed(function(Use)
				local TableValue = Use(Table) or {}
				local InProps = Use(Props.Table) ~= nil

				if InProps and (Use(TableValue.Enabled) ~= false) then
					return Scope:New "UITableLayout" {
						Padding = TableValue.Padding,
						FillEmptySpaceColumns = TableValue.FillEmptySpaceColumns,
						FillEmptySpaceRows = TableValue.FillEmptySpaceRows,
						FillDirection = TableValue.FillDirection,
						SortOrder = TableValue.SortOrder,
						MajorAxis = TableValue.MajorAxis,
						HorizontalAlignment = TableValue.HorizontalAlignment,
						VerticalAlignment = TableValue.VerticalAlignment,
					}
				else
					return
				end
			end),
			Scope:Computed(function(Use)
				local PageValue = Use(Page) or {}
				local InProps = Use(Props.Page) ~= nil

				if InProps and (Use(PageValue.Enabled) ~= false) then
					return Scope:New "UIPageLayout" {
						Animated = PageValue.Animated,
						Circular = PageValue.Circular,
						EasingDirection = PageValue.EasingDirection,
						EasingStyle = PageValue.EasingStyle,
						Padding = PageValue.Padding,
						TweenTime = PageValue.TweenTime,
						FillDirection = PageValue.FillDirection,
						SortOrder = PageValue.SortOrder,
						HorizontalAlignment = PageValue.HorizontalAlignment,
						VerticalAlignment = PageValue.VerticalAlignment,
						GamepadInputEnabled = PageValue.GamepadInputEnabled,
						ScrollWheelInputEnabled = PageValue.ScrollWheelInputEnabled,
						TouchInputEnabled = PageValue.TouchInputEnabled,
					}
				end
			end),
			Scope:Computed(function(Use)
				local FlexValue = Use(Props.Flex) or {}
				local InProps = Use(Props.Flex) ~= nil

				if InProps and (Use(FlexValue.Mode) ~= Enum.UIFlexMode.None) then
					return Scope:New "UIFlexItem" {
						FlexMode = FlexValue.Mode,
						FlexItemLineAlignment = FlexValue.ItemLineAlignment,
						FlexGrowRatio = FlexValue.GrowRatio,
						FlexShrinkRatio = FlexValue.ShrinkRatio,
					}
				end
			end),

			Props[Children],
		},
	}
end
