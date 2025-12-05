--!strict
-- LOCAL
local InputObjects = {}


-- OBJECTS
InputObjects.items = {
	
	["ItemSelector"] = function(inputConfig: InputConfig)
		-- An object that allows the user to select an item from a list of items
		-- This will be primarily used as a player selector, but will be used too for
		-- picking items such as 'Tools' and 'Roles' from an array. It's desirable to
		-- have custom icons for many item types, for example, the player's profile image,
		-- for Player instances.
		-- This object also needs textbox (that is by default hidden, but enabled through
		-- settings such as 'getPickerItemsFromAnyUser') that enables the user to enter
		-- a UserId or UserName, and if valid, adds that user to the item selector.
		local getPickerItemsFromAnyUser = inputConfig.getPickerItemsFromAnyUser
		local getPickerItemsFromServerPlayers = inputConfig.getPickerItemsFromServerPlayers
		local pickerName = inputConfig.pickerName
		local pickerGetter = inputConfig.pickerGetter
		if pickerGetter then
			local items = pickerGetter()
			for _, item in items do
				if typeof(item) == "Instance" then
					if item:IsA("Player") then
						-- Set icon as player's UserId image
					elseif item:IsA("Tool") then
						-- Set icon as tool's image
					end
				end
			end
		end
	end,

	["TextInput"] = function(inputConfig: InputConfig)
		-- This is a textbox that allows the user to enter text. If filterText is true,
		-- it will also additionally filter text upon focus lost. A success or fail
		-- icon is displayed within and to the right of the box to indicate if the 
		-- text box passed filtering.
		local filterText = inputConfig.filterText
	end,

	["NumberSlider"] = function(inputConfig: InputConfig)
		-- A number slider you can drag left and right with the option to customize the
		-- 'stepAmount' (the increment it shifts when dragged), and it's min and max values
		-- which are displayed. It's worth noting, even with min and max values, the numberSlider
		-- will always represent a value internally between 1 and 0.
		local minValue = inputConfig.minValue
		local maxValue = inputConfig.maxValue
		local stepAmount = inputConfig.stepAmount
	end,

	["NumberInput"] = function(inputConfig: InputConfig)
		-- Similar to TextInput, but only permits numbers to be entered, and is smaller
		-- in width, being positioned to the right, while it has a text label describing
		-- it's value on the left.
		local minValue = inputConfig.minValue
		local maxValue = inputConfig.maxValue
		local stepAmount = inputConfig.stepAmount
		local pickerText = inputConfig.pickerText
	end,

	["DurationSelector"] = function(inputConfig: InputConfig)
		-- An object that enables the user to configure duration, including
		-- seconds (optional), minutes, hours, days, and years (optional).
	end,

	["ColorPicker"] = function(inputConfig: InputConfig)
		-- An object that initially displays a color, and when clicked, opens a 
		-- color picker. The color picker allows the user to select a color, and
		-- when the user selects a color, it will update the color of the object.
		local pickerText = inputConfig.pickerText
	end,

	["Toggle"] = function(inputConfig: InputConfig)
		-- A simple toggle switch with text on it's left describing the toggle
	end,

	["Options"] = function(inputConfig: InputConfig)
		-- Takes optionsArray, and creates a list of buttons that the user can
		-- select from. Selecting one button, will deselect the other buttons.
		-- This is used for example in the HD Admin ban menu where you can select
		-- 'Servers to ban from' with options 'All Servers' and 'Current Server'
		local optionsArray = inputConfig.optionsArray
	end,

	["InputFields"] = function(inputConfig: InputConfig)
		-- An object where you can add 'TextInputs' (up to maxItems or 10), and
		-- then also delete these textboxes. This is used for example in the HD Admin
		-- poll menu.
		local maxItems = inputConfig.maxItems
	end,

}


-- TYPES
export type InputType = keyof<typeof(InputObjects.items)>
export type InputConfig = {
	inputType: InputType?,
	onlySelectOne: boolean?,
	filterText: boolean?,
	maxItems: number?,
	minValue: number?,
	maxValue: number?,
	stepAmount: number?,
	pickerName: string?,
	pickerText: string?,
	pickerGetter: ((...any) -> ({any}))?,
	getPickerItemsFromServerPlayers: boolean?,
	getPickerItemsFromAnyUser: boolean?,
	preventWhitespaces: boolean?,
	optionsArray: {string}?, -- Array of strings to be used as options for the Options input type
}


-- RETURN
return InputObjects