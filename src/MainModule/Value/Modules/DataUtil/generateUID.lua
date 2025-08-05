--!strict
type Limiter = "Letters" |  "LettersAndNumbers"

local validCharacters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","<",">","?","@","{","}","[","]","!","(",")","=","+","~","#"}

local function getListForLimiter(limiter: Limiter?)
	local list = {}
	if limiter == "Letters" then
		for _, char in (validCharacters) do
			table.insert(list, char)
			if char == "Z" then
				return list
			end
		end
	elseif limiter == "LettersAndNumbers" then
		for _, char in (validCharacters) do
			table.insert(list, char)
			if char == "0" then
				return list
			end
		end
	elseif limiter ~= nil then
		error(`Limiter '{limiter}' does not exist!`)
	end
	return validCharacters
end

return function (length: number, limiter: Limiter?): string
	length = length or 8
	local UID = ""
	local list = getListForLimiter(limiter)
	local total = #list
	for i = 1, length do
		local randomCharacter = list[math.random(1, total)] :: any
		UID = UID..randomCharacter
	end
	return UID
end