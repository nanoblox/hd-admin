local Spawn = require(script.Parent.Spawn)

export type Future<T...> = {
	ValueList: { any }?,
	AfterList: { (T...) -> () },
	YieldList: { thread },

	IsComplete: (self: Future<T...>) -> boolean,
	IsPending: (self: Future<T...>) -> boolean,

	Expect: (self: Future<T...>, Message: string) -> T...,
	Unwrap: (self: Future<T...>) -> T...,
	UnwrapOr: (self: Future<T...>, T...) -> T...,
	UnwrapOrElse: (self: Future<T...>, Else: () -> T...) -> T...,

	After: (self: Future<T...>, Callback: (T...) -> ()) -> (),
	Await: (self: Future<T...>) -> T...,
}

local function IsComplete<T...>(self: Future<T...>): boolean
	return self.ValueList ~= nil
end

local function IsPending<T...>(self: Future<T...>): boolean
	return self.ValueList == nil
end

local function Expect<T...>(self: Future<T...>, Message: string): T...
	assert(self.ValueList, Message)

	return table.unpack(self.ValueList)
end

local function Unwrap<T...>(self: Future<T...>): T...
	return self:Expect("Attempt to unwrap pending future!")
end

local function UnwrapOr<T...>(self: Future<T...>, ...): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		return ...
	end
end

local function UnwrapOrElse<T...>(self: Future<T...>, Else: () -> T...): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		return Else()
	end
end

local function After<T...>(self: Future<T...>, Callback: (T...) -> ()): T...
	if self.ValueList then
		Spawn(Callback, table.unpack(self.ValueList))
	else
		table.insert(self.AfterList, Callback)
	end
end

local function Await<T...>(self: Future<T...>): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		table.insert(self.YieldList, coroutine.running())

		return coroutine.yield()
	end
end

local function Future<T..., A...>(Callback: (A...) -> T..., ...: A...): Future<T...>
	local self: Future<T...> = {
		ValueList = nil,
		AfterList = {},
		YieldList = {},

		IsComplete = IsComplete,
		IsPending = IsPending,

		Expect = Expect,
		Unwrap = Unwrap,
		UnwrapOr = UnwrapOr,
		UnwrapOrElse = UnwrapOrElse,

		After = After,
		Await = Await,
	} :: any

	Spawn(function(self: Future<T...>, Callback: (A...) -> T..., ...: A...)
		local ValueList = { Callback(...) }
		self.ValueList = ValueList

		for _, Thread in self.YieldList do
			task.spawn(Thread, table.unpack(ValueList))
		end

		for _, Callback in self.AfterList do
			Spawn(Callback, table.unpack(ValueList))
		end
	end, self, Callback, ...)

	return self
end

local function Try<T..., A...>(Callback: (A...) -> T..., ...: A...): Future<(boolean, T...)>
	return Future(pcall, Callback, ...)
end

return {
	new = Future,
	Try = Try,
}
