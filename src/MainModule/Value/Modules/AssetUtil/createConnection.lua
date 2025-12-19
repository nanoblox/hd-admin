export type Disconnect = {Disconnect: (any?) -> ()}
return function(disconnectCallback): Disconnect
	local connection = {}
	function connection.disconnect(connection: any?)
		disconnectCallback()
	end
	connection.Disconnect = connection.disconnect
	connection.Destroy = connection.disconnect
	return connection
end