local STORY_EXTENSION = ".story"

local Components = {
	Base = require(script.Base),
	Text = require(script.Text),
	Frame = require(script.Frame),
	Badge = require(script.Badge),
	Avatar = require(script.Avatar),
	AutoScaler = require(script.AutoScaler),
	BaseButton = require(script.BaseButton),
	Button = require(script.Button),
	Card = require(script.Card),
	Checkbox = require(script.Checkbox),
	Divider = require(script.Divider),
	Group = require(script.Group),
	Heading = require(script.Heading),
	Icon = require(script.Icon),
	IconButton = require(script.IconButton),
	IconText = require(script.IconText),
	Image = require(script.Image),
	ProgressBar = require(script.ProgressBar),
	Scroller = require(script.Scroller),
	Switch = require(script.Switch),
	TextInput = require(script.TextInput),
	TextArea = require(script.TextArea),
	TitleBar = require(script.TitleBar),
	TextSwap = require(script.TextSwap),
	Slider = require(script.Slider),
	Tabs = require(script.Tabs),
	IconSwap = require(script.IconSwap),
}

task.spawn(function()
	for _, Child in ipairs(script:GetChildren()) do
		local LastCharacters = string.sub(Child.Name, -string.len(STORY_EXTENSION))
		if LastCharacters ~= STORY_EXTENSION then
			local Success, Result = pcall(function()
				return require(Child)
			end)
			if Success then
				if Components[Child.Name] ~= Result then
					assert(false, `Component {Child} is not listed.`)
				end
			else
				assert(false, `{Child} errored during require.`)
			end
		end
	end
end)

return Components
