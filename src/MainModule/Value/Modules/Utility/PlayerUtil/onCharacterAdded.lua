--!strict
-- Similar to characterAdded except a one-time-use
return function(player: Player, callback)
    local character = player.Character
    if character then
        task.defer(callback, character)
    else
        player.CharacterAdded:Once(function(newChar)
            callback(newChar)
        end)
    end
end