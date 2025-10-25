-- This verifies what the client can access/see in the 'firstKey' table
-- For example, we may not went to send certain properties to the client such as
-- permissions or other sensitive info. It's also useful for verifying *who*
-- can view 'firstKey' (such as only players with roles that permit viewing roleInfo)
-- We do this as it saves us creating a duplicate table, and makes the syncing of data
-- easier to manage.

export type StateVerifierAction = "OnlyInclude" | "Exclude"

return function(firstKey: string, action: StateVerifierAction, actionTable: {any}, requiredRolePermission: string?)
	return function(player, pathway, value): (boolean, any)
		-- Return false to continue with incoming value, return true with a second value to send that value instead
		local totalKeys = #pathway
		local thisFirstKey = pathway[1]
		if thisFirstKey ~= firstKey then
			return false
		end
		-- !!! TO-DO: VERIFY PLAYER HAS PERMISSION TO VIEW ROLE INFO WITH requiredRolePermission
		if totalKeys == 3 then
			-- This is to ensure the client can't cleverly pass in a third key
			-- to access sensitive info
			local propertyName = pathway[3]
			if action == "OnlyInclude" and not table.find(actionTable, propertyName) then
				return true, nil
			end
			if action == "Exclude" and table.find(actionTable, propertyName) then
				return true, nil
			end
			return false
		end
		if totalKeys > 3 then
			return false
		end
		if typeof(value) ~= "table" then
			return false
		end
		local function updateTable(incomingTable)
			for k, v in incomingTable do
				if action == "OnlyInclude" and not table.find(actionTable, k) then
					incomingTable[k] = nil
				elseif action == "Exclude" and table.find(actionTable, k) then
					incomingTable[k] = nil
				end
			end
		end
		local tableToReturn: any = value
		if totalKeys == 2 then
			updateTable(tableToReturn)
		elseif totalKeys == 1 then
			for key, info in tableToReturn do
				if typeof(info) == "table" then
					updateTable(info)
				end
			end
		end
		return true, tableToReturn
	end
end