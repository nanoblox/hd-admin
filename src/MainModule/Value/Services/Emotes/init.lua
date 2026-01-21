--!strict

-- CONFIG
local MAX_FAVORITES = 50


-- LOCAL
local Emotes = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local AvatarEditorService = game:GetService("AvatarEditorService")
local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local getEmotesDe = false
local allEmotes: EmoteTable = {}
local loadingEmotes: {[string]: boolean} = {}
local lowestOrder = 0
local toPascalCase = require(modules.DataUtil.toPascalCase)
local emoteIdsArray: {number} = {}


-- TYPES
type EmoteTable = {[string]: Emote}
export type Emote = {
	name: string,
	originalName: string?,
	order: number,
	animationId: number,
	emoteId: number,
}
export type IncompleteEmote = {
	name: string?,
	originalName: string?,
	order: number?,
	animationId: number?,
	emoteId: number,
}


-- FUNCTIONS
function Emotes.getEmotesAsync(): (boolean, EmoteTable | string)

	local isTableEmpty = require(modules.TableUtil.isTableEmpty)
	if getEmotesDe == true then
		repeat task.wait(0.2) until getEmotesDe ~= true
	end
	if not isTableEmpty(allEmotes) then
		return true, allEmotes
	end
	getEmotesDe = true

	-- This returns all emotes officially listed under HD Admin
	local searchResults = {}
	local nextPageCursor = nil
	local params = CatalogSearchParams.new() :: any
	params.AssetTypes = {Enum.AvatarAssetType.EmoteAnimation}
	params.CreatorType = Enum.CreatorTypeFilter.Group
	params.CreatorId = 4676369
	params.SortType = Enum.CatalogSortType.RecentlyCreated
	params.Limit = 120
	local success, catalogPages: any
	local waitTime = 1
	while true do
		success, catalogPages = pcall(function()
			return (AvatarEditorService :: any):SearchCatalog(params)
		end)
		if success then
			break
		end
		task.wait(waitTime)
		waitTime *= 2
	end
	repeat
		local currentPage = catalogPages:GetCurrentPage()
		for _, item in currentPage do
			table.insert(searchResults, item)
		end
		if catalogPages.IsFinished then
			break
		end
		local nextSuccess, warning = pcall(function()
			return catalogPages:AdvanceToNextPageAsync()
		end)
		if not nextSuccess then
			warn("Failed to advance to next page:", warning)
			break
		end
		task.wait(0.1)
	until catalogPages.IsFinished
	getEmotesDe = false
	if #searchResults == 0 then
		return false, "Unable to retrieve Emotes"
	end
	
	-- This organises the returned data into a dictionary of emotes
	local defaultEmotes = require(script.defaultEmotes) :: EmoteTable
	allEmotes = {}
	for emoteId, emote in defaultEmotes do
		allEmotes[emoteId] = emote
	end
	for i, result in searchResults do
		local emoteId = tostring(result.Id)
		if not emoteId then
			continue
		end
		local existing = allEmotes[emoteId]
		local existingOriginalName = existing and existing.originalName
		local originalName = existingOriginalName or tostring(result.Name)
		local name = if existing and existing.name then existing.name else toPascalCase(originalName)
		local emote: any = {
			name = name,
			originalName = originalName,
			order = i,
		}
		allEmotes[emoteId] = emote
	end
	local itemsRemaining = 0
	local Assets = require(modules.Parent.Services.Assets)
	for emoteId, emote in allEmotes do
		-- We have to use LoadAssetAsync on the EmoteId to retrieve the animationId
		-- the animationId which is used by the client to display an animated rig
		local emoteIdNumber = tonumber(emoteId)
		if not emoteIdNumber then
			continue
		end
		if not emote.emoteId then
			emote.emoteId = emoteIdNumber
		end
		Assets.permitAsset(emoteIdNumber)
		itemsRemaining += 1
		task.spawn(function()
			local success, warning = Emotes.addEmoteAsync(emote :: any, true)
			if not success then
				allEmotes[emoteId] = nil
				warn(`HD Admin: Failed to load emote animationId ({emoteId}): {warning}`)
			end
			itemsRemaining -= 1
		end)
	end

	-- Wait until all animation data loaded
	repeat task.wait() until itemsRemaining == 0

	-- Update to everyone state so clients can access
	local User = require(modules.Objects.User)
	User.everyone:set("Emotes", allEmotes)

	return true, allEmotes
end

function Emotes.getEmoteById(emoteId: number): Emote?
	Emotes.getEmotesAsync()
	local emoteIdString = tostring(emoteId)
	local emote = allEmotes[emoteIdString]
	return emote
end

function Emotes.getEmoteByName(emoteName: string, matchLength: boolean?): Emote?
	Emotes.getEmotesAsync()
	local emoteNameLower = string.lower(emoteName)
	for _, emoteToCheck in allEmotes do
		local toCheckName = string.lower(emoteToCheck.name)
		local length = if matchLength == true then #emoteNameLower else #toCheckName
		if toCheckName:sub(1, length) == emoteNameLower then
			return emoteToCheck
		end
	end
	return nil
end

function Emotes.getRandomEmote(): Emote?
	Emotes.getEmotesAsync()
	if #emoteIdsArray == 0 then
		return nil
	end
	local randomIndex = math.random(1, #emoteIdsArray)
	local emoteId = emoteIdsArray[randomIndex]
	return Emotes.getEmoteById(emoteId)
end

function Emotes.addEmoteAsync(emote: IncompleteEmote, dontRegister: boolean?): (boolean, Emote | string)
	local emoteId = emote.emoteId
	if not emoteId then
		return false, "EmoteId is required"
	end
	local stringId = tostring(emoteId)
	if loadingEmotes[stringId] then
		repeat task.wait(0.05) until loadingEmotes[stringId] == nil
	end
	local alreadyLoadedEmote = not dontRegister and allEmotes[stringId]
	if alreadyLoadedEmote then
		return true, alreadyLoadedEmote
	end
	local function endLoading()
		loadingEmotes[stringId] = nil
	end
	loadingEmotes[stringId] = true
	local deepCopyTable = require(modules.TableUtil.deepCopyTable)
	local completeEmote = deepCopyTable(emote) :: Emote
	if not completeEmote.animationId or not completeEmote.originalName then
		local success, assetOrWarning = pcall(function()
			return AssetService:LoadAssetAsync(emoteId)
		end)
		if not completeEmote.animationId then
			local animationId
			if success then
				local animationObject = assetOrWarning:FindFirstChildWhichIsA("Animation", true)
				local animationString = animationObject and animationObject.AnimationId
				animationId = animationString and tonumber(string.match(animationString, "%d+"))
			end
			if typeof(animationId) ~= "number" or not success then
				endLoading()
				return false, `HD Admin: Failed to load emote animationId ({emoteId}): {assetOrWarning}`
			end
			completeEmote.animationId = animationId
		end
		if not completeEmote.originalName then
			local success, assetInfo = pcall(function()
				return MarketplaceService:GetProductInfo(emoteId)
			end)
			local assetName = emote.name or "UnknownEmote"
			if success and assetInfo and assetInfo.Name then
				assetName = assetInfo.Name :: string
			end
			completeEmote.originalName = assetName
		end
	end
	local updatedName = completeEmote.name or completeEmote.originalName
	local emoteOrder = completeEmote.order
	completeEmote.name = toPascalCase(updatedName :: string)
	if emoteOrder and emoteOrder < lowestOrder then
		lowestOrder = emoteOrder - 1
	elseif not emoteOrder then
		lowestOrder -= 1
		completeEmote.order = lowestOrder
	end
	if not dontRegister then
		local User = require(modules.Objects.User)
		allEmotes[stringId] = completeEmote
		User.everyone:set("Emotes", stringId, completeEmote)
	end
	local Assets = require(modules.Parent.Services.Assets)
	Assets.permitAsset(emoteId)
	endLoading()
	table.insert(emoteIdsArray, emoteId)
	return true, completeEmote
end


-- SETUP
-- This is essential to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.verifyFirstFetch("Emotes", Emotes.getEmotesAsync)

-- This listens for and handles the favoriting of emotes
local Remote = require(modules.Objects.Remote)
Remote.new("FavoriteEmote", "Function"):onServerInvoke(function(player: Player, assetId: unknown, shouldFavorite: unknown): (boolean, any)
	if typeof(assetId) ~= "number" and typeof(assetId) ~= "string" then
		return false, "Invalid assetId (1)"
	end
	assetId = tonumber(assetId)
	if not assetId then
		return false, "Invalid assetId (2)"
	end
	shouldFavorite = if shouldFavorite == true then true else false
	local emoteId = tostring(assetId)
	local emote = allEmotes[emoteId]
	if not emote then
		return false, "Invalid EmoteId"
	end
	local User = require(modules.Objects.User)
	local user = User.getUser(player)
	if not user then
		return false, "User not loaded"
	end
	local perm = user.perm
	local favoritedEmotes = perm:get("FavoritedEmotes")
	local getTableSize = require(modules.TableUtil.getTableSize)
	if shouldFavorite and getTableSize(favoritedEmotes) >= MAX_FAVORITES then
		return false, `Can only favorite max {MAX_FAVORITES} items - remove some then retry.`
	end
	if shouldFavorite then
		perm:set("FavoritedEmotes", emoteId, emote)
		return true, emote
	else
		perm:set("FavoritedEmotes", emoteId, nil)
		return true, nil
	end
end)


return Emotes