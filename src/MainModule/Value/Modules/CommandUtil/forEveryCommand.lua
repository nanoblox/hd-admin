-- A command module can return a single command table, OR an array of command tables
-- This checks what is what, and then simply calls 'callback' for every command found
return function(moduleReference, callback)
	local function checkIfCommand(command)
		if typeof(command.name) == "string" and typeof(command.run) == "function" then
			callback(command)
		end
	end
	if typeof(moduleReference) == "table" then
		-- If it's an array of commands, loop through and call callback for each one
		if #moduleReference > 0 then
			for _, command in moduleReference do
				checkIfCommand(command)
			end
		else
			-- Otherwise just call the callback once with the table
			checkIfCommand(moduleReference)
		end
	end
end