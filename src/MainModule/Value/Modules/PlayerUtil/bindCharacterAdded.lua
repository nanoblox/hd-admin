--!strict
-- This differs to the traditional player.CharacterAdded as callback will still be called
-- even if the character has already loaded
return function(player: Player, callback)
	player.CharacterAdded:Connect(callback)
	local character = player.Character
	if character then
		task.defer(callback, character)
	end
end