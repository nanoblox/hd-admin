local Components = require(script.Components)
local Util = require(script.Util)
local Themer = require(script.Themer)

local Base = require(script.Components.Base)
local Text = require(script.Components.Text)
local Frame = require(script.Components.Frame)
local Badge = require(script.Components.Badge)
local Avatar = require(script.Components.Avatar)
local AutoScaler = require(script.Components.AutoScaler)
local BaseButton = require(script.Components.BaseButton)
local Button = require(script.Components.Button)
local Card = require(script.Components.Card)
local Checkbox = require(script.Components.Checkbox)
local Divider = require(script.Components.Divider)
local Group = require(script.Components.Group)
local Heading = require(script.Components.Heading)
local Icon = require(script.Components.Icon)
local IconButton = require(script.Components.IconButton)
local IconText = require(script.Components.IconText)
local Image = require(script.Components.Image)
local ProgressBar = require(script.Components.ProgressBar)
local Scroller = require(script.Components.Scroller)
local Switch = require(script.Components.Switch)
local TextInput = require(script.Components.TextInput)
local TextArea = require(script.Components.TextArea)
local TitleBar = require(script.Components.TitleBar)
local TextSwap = require(script.Components.TextSwap)
local Slider = require(script.Components.Slider)
local IconSwap = require(script.Components.IconSwap)
local Tabs = require(script.Components.Tabs)

export type Theme = Themer.Theme
export type ThemeSpec = Themer.ThemeSpec

export type BaseProps = Base.Props
export type TextProps = Text.Props
export type FrameProps = Frame.Props
export type BadgeProps = Badge.Props
export type AvatarProps = Avatar.Props
export type AutoScalerProps = AutoScaler.Props
export type BaseButtonProps = BaseButton.Props
export type ButtonProps = Button.Props
export type CardProps = Card.Props
export type CheckboxProps = Checkbox.Props
export type DividerProps = Divider.Props
export type GroupProps = Group.Props
export type HeadingProps = Heading.Props
export type IconProps = Icon.Props
export type IconButtonProps = IconButton.Props
export type IconTextProps = IconText.Props
export type ImageProps = Image.Props
export type ProgressBarProps = ProgressBar.Props
export type ScrollerProps = Scroller.Props
export type SwitchProps = Switch.Props
export type TextInputProps = TextInput.Props
export type TextAreaProps = TextArea.Props
export type TitleBarProps = TitleBar.Props
export type TextSwapProps = TextSwap.Props
export type IconSwapProps = IconSwap.Props
export type SliderProps = Slider.Props
export type TabsProps = Tabs.Props

export type CornerProps = Base.CornerProps
export type PaddingProps = Base.PaddingProps
export type StrokeProps = Base.StrokeProps
export type GradientProps = Base.GradientProps
export type AspectProps = Base.AspectProps
export type ScaleProps = Base.ScaleProps

export type ListProps = Base.ListProps
export type GridProps = Base.GridProps
export type TableProps = Base.TableProps
export type PageProps = Base.PageProps
export type FlexProps = Base.FlexProps

export type SizeLimitProps = Base.SizeLimitProps
export type TextSizeLimitProps = Base.TextSizeLimitProps

return {
	Util = Util,
	Components = Components,
	Themer = Themer,
}
