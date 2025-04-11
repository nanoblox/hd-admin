-- LOCAL
--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Janitor = require(modules.Objects.Janitor)
local Queue = {}
Queue.__index = Queue


-- CONSTRUCTOR
function Queue.new()

	-- Define properties
	-- I made this before this before type checking existed, so will convert to properly
	-- typed another time instead of defining everything as 'any'
	local Signal = require(modules.Objects.Signal)
	local janitor = Janitor.new()
	local self = {
		janitor = janitor,
		sortEveryCall = false :: any,
		sortCooldown = 0.5 :: any,
		callbackGroups = {} :: any,
		processing = false :: any,
		isSorting = false :: any,
		isRequestingSort = false :: any,
		sorted = janitor:add(Signal.new() :: any),
		started = janitor:add(Signal.new() :: any),
		ended = janitor:add(Signal.new() :: any),
		hasStarted = false :: any,
		isActive = true :: any,
		sortByFunction = nil :: any,
	}
	setmetatable(self, Queue)

	return self
end


-- CLASS
export type Class = typeof(Queue.new(...))


-- METHODS
function Queue.requestSort(self: Class)
	local sortFunc = self.sortByFunction
	if sortFunc then
		local function sort()
			if self.isSorting then
				self.isRequestingSort = true
			else
				self.isSorting = true
				table.sort(self.callbackGroups, sortFunc :: any)
				self.sorted:Fire(self.callbackGroups)
				task.delay(self.sortCooldown, function()
					self.isSorting = false
					if self.isRequestingSort then
						self.isRequestingSort = false
						sort()
					end
				end)
			end
		end
		sort()
	end
end

function Queue._add(self: Class, index, incomingCallback, sortValue)
	local callback = incomingCallback
	if self.sortEveryCall then
		local function newCallback()
			self:requestSort()
			incomingCallback()
		end
		callback = newCallback
	end
	table.insert(self.callbackGroups :: {any}, {callback, sortValue})
	self:requestSort()
	task.spawn(function()
		self:next()
	end)
end

function Queue.add(self: Class, callback, sortValue)
	self:_add(nil, callback, sortValue)
end

function Queue.customAdd(self: Class, index, callback, sortValue)
	self:_add(index, callback, sortValue)
end

function Queue.sortBy(self: Class, func)
	self.sortByFunction = func
end

function Queue.sortByEveryCall(self: Class, cooldown, func)
	self.sortEveryCall = true
	self.sortCooldown = cooldown or self.sortCooldown
	self:sortBy(func)
	task.defer(function()
		self:requestSort()
	end)
end

function Queue.getSize(self: Class)
	return #self.callbackGroups
end

function Queue.next(self: Class)
	if self.processing or self.isActive == false then
		return
	end
	local group = self.callbackGroups[1] :: {any}
	if not group then
		self.hasStarted = false
		self.ended:Fire()
		return
	end
	if not self.hasStarted then
		self.hasStarted = true
		self.started:Fire()
	end
	self.processing = true
	local callback = group[1]
	table.remove(self.callbackGroups, 1)
	callback()
	self.processing = false
	self:next()
end

function Queue.completeAsync(self: Class)
	local itemsToCall = self.callbackGroups
	self.callbackGroups = {}
	local tasksCompleting = 0
	for _, group in (itemsToCall) do
		local callback = group[1]
		tasksCompleting += 1
		task.spawn(function()
			callback()
			tasksCompleting -= 1
		end)
	end
	task.delay(2, function()
		tasksCompleting = 0
	end)
	while tasksCompleting > 0 do
		task.wait()
	end
end

function Queue.clear(self: Class)
	self.callbackGroups = {}
end

function Queue.destroy(self: Class)
	if self.isActive == false then
		return
	end
	self.isActive = false :: any
	self.callbackGroups = {}
	self.janitor:destroy()
end


return Queue