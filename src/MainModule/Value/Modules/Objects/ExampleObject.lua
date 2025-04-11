-- LOCAL
--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Janitor = require(modules.Objects.Janitor)
local ExampleObject = {}
ExampleObject.__index = ExampleObject


-- CONSTRUCTOR
function ExampleObject.new()

	-- Define properties
	local janitor = Janitor.new()
	local self = {
		janitor = janitor,
		isActive = true,
	}
	setmetatable(self, ExampleObject)

	return self
end


-- CLASS
export type Class = typeof(ExampleObject.new(...))


-- METHODS
function ExampleObject.destroy(self: Class)
	if self.isActive then
		self.isActive = false :: any
		self.janitor:destroy()
	end
end


return ExampleObject