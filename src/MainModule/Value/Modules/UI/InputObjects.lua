--!strict
-- LOCAL
local InputObjects = {}


-- OBJECTS
InputObjects.items = {

	["ItemSelector"] = function(inputConfig: InputConfig)
		-- Useful for custom arrays of items to select from such as 'Tools'
		local pickerName = inputConfig.pickerName
		local pickerItems = inputConfig.pickerItems
		if pickerItems then
			local items = pickerItems()
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
		local filterText = inputConfig.filterText
	end,

	["TextOptions"] = function(inputConfig: InputConfig)
		local maxItems = inputConfig.maxItems
	end,


	["NumberSlider"] = function(inputConfig: InputConfig)
		local minValue = inputConfig.minValue
		local maxValue = inputConfig.maxValue
		local stepAmount = inputConfig.stepAmount
	end,

	["NumberInput"] = function(inputConfig: InputConfig)
		local minValue = inputConfig.minValue
		local maxValue = inputConfig.maxValue
		local stepAmount = inputConfig.stepAmount
	end,

	["TimeSelector"] = function(inputConfig: InputConfig)
		
	end,

	["ColorPicker"] = function(inputConfig: InputConfig)
		
	end,

	["Toggle"] = function(inputConfig: InputConfig)
		
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
	pickerItems: ((any) -> (any))?,
	getPickerItemsFromServerPlayers: boolean?,
	getPickerItemsFromAnyPlayer: boolean?,
	preventWhitespaces: boolean?,
}


-- RETURN
return InputObjects