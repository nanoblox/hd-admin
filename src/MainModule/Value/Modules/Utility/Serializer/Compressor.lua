--!nocheck
local lzw = {}
lzw.__index = lzw
--local concatSize = 512

lzw.new = function(BUF_SIZE: number?)
	local self = setmetatable({}, lzw)
	
	self.BUF_SIZE = BUF_SIZE or 8388608 --* 8 MB should be enough for most things on Roblox
	self.buf = buffer.create(self.BUF_SIZE)
	--self.concat = buffer.create(concatSize) -- storage to concat strings (is this faster?)
	--local concat = self.concat

	self.strToLength = {}
	self.lengthToStr = buffer.create(94) -- base93
	self.bidirectionalDict = {}

	local lengthToStr = self.lengthToStr
	local strToLength = self.strToLength
	local bidirectionalDict = self.bidirectionalDict

	do -- populate dictionary
		local length = 0
		for i = 32, 127 do
			if i ~= 34 and i ~= 92 then
				local c = string.char(i)
				strToLength[c] = length

				bidirectionalDict[length] = c
				bidirectionalDict[c] = length

				buffer.writeu8(lengthToStr, length, i)
				length = length + 1
			end
		end
	end


	local escapemap_126, escapemap_127 = {}, {}
	local unescapemap_126, unescapemap_127 = {}, {}

	local blacklisted_126 = { 34, 92 }
	for i = 126, 180 do
		table.insert(blacklisted_126, i)
	end

	do -- Populate escape map
		-- represents the numbers 0-31, 34, 92, 126, 127 (36 characters)
		-- and 128-180 (52 characters)
		-- https://devforum.roblox.com/t/text-compression/163637/5
		for i = 0, 31 + #blacklisted_126 do
			local b = blacklisted_126[i - 31]
			local s = i + 32

			-- Note: 126 and 127 are magic numbers
			local c = b or i
			local e = s + (s >= 34 and 1 or 0) + (s >= 91 and 1 or 0)

			escapemap_126[c] = e
			unescapemap_126[string.char(e)] = string.char(c)
		end

		for i = 1, 255 - 180 do
			local c = i + 180
			local s = i + 34
			local e = s + (s >= 92 and 1 or 0)

			escapemap_127[c] = e
			unescapemap_127[string.char(e)] = string.char(c)
		end
	end

	local function escape(s : string)
		local len = #s
		local refbuf = buffer.fromstring(s)
		local newbuf = buffer.create(len * 2) -- worst case scenario

		local c = 1 -- 1 indexed
		local f = string.find(s, '[%c"\\\126-\255]') -- 1 indexed
		local bufcursor = 0

		while f do
			if c < f then
				buffer.copy(newbuf, bufcursor, refbuf, c - 1, f - c)
				bufcursor += f - c
				c = f
			end

			local byte = buffer.readu8(refbuf, f - 1)
			if byte >= 181 then
				local e = escapemap_127[byte]
				buffer.writeu8(newbuf, bufcursor, 127)
				buffer.writeu8(newbuf, bufcursor + 1, e)
			else
				local e = escapemap_126[byte]
				buffer.writeu8(newbuf, bufcursor, 126)
				buffer.writeu8(newbuf, bufcursor + 1, e)
			end

			c += 1
			bufcursor += 2
			f = string.find(s, '[%c"\\\126-\255]', f + 1)
		end

		if c <= len then
			buffer.copy(newbuf, bufcursor, refbuf, c - 1, len - c + 1)
			bufcursor += len - c + 1
		end

		return newbuf, bufcursor
	end

	local function unescape(s : string)
		return string.gsub(string.gsub(s, "\127(.)", function(e)
			return unescapemap_127[e]
		end), "\126(.)", function(e)
			return unescapemap_126[e]
		end)
	end

	local b10Cache = {}

	local function tobase10(value: string) : number
		local n = b10Cache[value]
		if n then
			return n
		end

		n = 0
		for i = 1, #value do
			n = n + math.pow(93, i - 1) * bidirectionalDict[string.sub(value, -i, -i)]
		end

		b10Cache[value] = n
		return n
	end

	self.escape = escape
	self.unescape = unescape
	--self.tobase93 = tobase93
	self.tobase10 = tobase10

	return self
end

function lzw:compress(text: string)
	assert(type(text) == "string", "bad argument #1 to 'compress' (string expected, got " .. typeof(text) .. ")")

	local buf, len = self.escape(text)
	local dictionaryCopy : {[string] : number} = table.clone(self.strToLength)
	local sequence: buffer, size : number = self.buf, 93
	local width: number, spans: {[number]: number}, span : number = 1, {}, 0
	local ptrA: number, ptrB: number = 0, 1
	local key: string = ""
	local cursor : number = 0
	local lengthToStr : buffer = self.lengthToStr
	local depth : number

	local writeasbase93 = function(n: number) : string
		local sz = 0
		repeat
			local remainder = n % 93
			buffer.copy(sequence, cursor + depth - 1 - sz, lengthToStr, remainder, 1)
			n = (n - remainder) / 93
			sz += 1
		until n == 0
	end

	local function listkey(k : string)  -- string to length
		local n = dictionaryCopy[k]
		depth = n == 0 and 1 or math.ceil(math.log(n + 1, 93))
		if depth > width then
			width, span, spans[width] = depth, 0, span
		end

		for _ = 1, width - depth do
			buffer.writeu8(sequence, cursor, 32)
			cursor += 1
		end
		writeasbase93(n)
		cursor += depth

		span += 1
	end

	while ptrB <= len do
		local new : string = buffer.readstring(buf, ptrA, ptrB - ptrA)

		if dictionaryCopy[new] then
			key = new
			ptrB += 1
		else
			listkey(key)
			ptrA = ptrB - 1
			size += 1
			dictionaryCopy[new] = size
		end
	end
	listkey(key)

	spans[width] = span

	return table.concat(spans, ",") .. "|" .. buffer.readstring(sequence, 0, cursor)
end

function lzw:decompress(text: string)
	assert(type(text) == "string", "bad argument #1 to 'decompress' (string expected, got " .. typeof(text) .. ")")
	local dictionaryCopy = table.clone(self.bidirectionalDict)
	local tobase10 = self.tobase10
	local sequence, spans, content = {}, string.match(text, "(.-)|(.*)")
	local groups, start = {}, 1
	for span in string.gmatch(spans, "%d+") do
		local width = #groups + 1
		groups[width] = string.sub(content, start, start + span * width - 1)
		start = start + span * width
	end
	local previous

	for width, group in ipairs(groups) do
		for value in string.gmatch(group, string.rep(".", width)) do
			local entry = dictionaryCopy[tobase10(value)]
			if previous then
				if entry then
					table.insert(dictionaryCopy, previous .. string.sub(entry, 1, 1))
				else
					entry = previous .. string.sub(previous, 1, 1)
					table.insert(dictionaryCopy, entry)
				end
				table.insert(sequence, entry)
			else
				sequence[1] = entry
			end
			previous = entry
		end
	end
	return self.unescape(table.concat(sequence))
end

return lzw.new()