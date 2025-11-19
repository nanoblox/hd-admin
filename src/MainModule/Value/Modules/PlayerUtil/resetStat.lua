--!strict
return function(player: Player, statName: string)
	local getStat = require(script.Parent.getStat)
	local stat = getStat(player, statName)
	if stat then
		if stat:IsA("StringValue") then
			stat.Value = ""
		elseif stat:IsA("NumberValue") or stat:IsA("IntValue") then
			stat.Value = 0
		end
	end
	return
end
