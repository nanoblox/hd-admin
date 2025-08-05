--!strict
local getAnimator = require(script.Parent.getAnimator)
return function(player: Player?, animationId): (AnimationTrack?, Animation?)
    local animator = getAnimator(player)
	if not animator or not player then
		return nil, nil
	end
	local character = player.Character
	local animation = Instance.new("Animation")
	animation.Name = animationId
	animation.AnimationId = "rbxassetid://"..animationId
	animation.Parent = character
	local track = animator:LoadAnimation(animation)
	return track, animation
end