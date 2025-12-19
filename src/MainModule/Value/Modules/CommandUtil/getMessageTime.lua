return function(message: string): number
	local length = string.len(message)
	local messageTime = (2+(length*0.08))
	if messageTime > 10 then
		messageTime = 10
	end
	return messageTime
end