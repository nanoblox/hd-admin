local main = require(game.Nanoblox)
local Command =	{}



Command.name = script.Name
Command.description = "Morphs you into that person"
Command.aliases	= {}
Command.opposites = {}
Command.tags = {"Appearance"}
Command.prefixes = {}
Command.contributors = {82347291}
Command.blockPeers = false
Command.blockJuniors = false
Command.autoPreview = false
Command.requiresRig = main.enum.HumanoidRigType.None
Command.revokeRepeats = false
Command.preventRepeats = main.enum.TriStateSetting.False
Command.cooldown = 0
Command.persistence = main.enum.Persistence.None
Command.args = {"UnfilteredText"}

function Command.invoke(job, args)
	local text = unpack(args)
	if text then
		main.services.CommandService.executeSimpleStatement(job.callerUserId, "Char", {text}, {"me"})
	end
end



return Command