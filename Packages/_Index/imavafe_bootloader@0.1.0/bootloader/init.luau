local STAGES = {
	"Created",
	"Initialized",
	"Started",
	"Destroyed",
}

local function NewBootloader(ModuleScripts: { ModuleScript })
	local Bootloader = {
		Stage = STAGES[1],
		Systems = {},
	}

	function Bootloader:Destroy()
		assert(Bootloader.Stage == STAGES[3], `Must be at stage {STAGES[3]}.`)
		Bootloader.Stage = STAGES[4]

		for _, System in ipairs(Bootloader.Systems) do
			if System.Destroy ~= nil then
				task.spawn(function()
					System:Destroy()
				end)
			end
		end
	end

	function Bootloader:Start()
		assert(Bootloader.Stage == STAGES[2], `Must be at stage {STAGES[2]}.`)
		Bootloader.Stage = STAGES[3]

		for _, System in ipairs(Bootloader.Systems) do
			if System.Start ~= nil then
				task.spawn(function()
					System:Start()
				end)
			end
		end
	end

	function Bootloader:Initialize()
		assert(Bootloader.Stage == STAGES[1], `Must be at stage {STAGES[1]}.`)
		Bootloader.Stage = STAGES[2]

		for _, ModuleScript in ipairs(ModuleScripts) do
			table.insert(Bootloader.Systems, require(ModuleScript))
		end
	end

	return Bootloader
end

return NewBootloader
