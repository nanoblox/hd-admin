local STORY_EXTENSION = ".story"

local Components = {}

for _, Child in ipairs(script:GetChildren()) do
	local LastCharacters = string.sub(Child.Name, -string.len(STORY_EXTENSION))
	if LastCharacters ~= STORY_EXTENSION then
		local Success, Result = pcall(function()
			return require(Child)
		end)
		if Success then
			if Components[Child.Name] ~= Result then
				warn(`Component`, Child, `is not listed.`)
			end
		else
			warn(Child, "errored during require.")
		end
	end
end

return Components
