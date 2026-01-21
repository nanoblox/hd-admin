--!strict
-- LOCAL
-- I'll update this in the future to also include the Chat Hijacker once again, or to
-- alternatively have every chat message produce from the target player automatically
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHead = require(modules.PlayerUtil.getHead)
local Remote = require(modules.Objects.Remote)
local Players = game:GetService("Players")
local controlAction = Remote.new("ControlAction", "Event")
local Prompt = require(modules.Prompt)


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "Control",
		aliases	= {"Hijak"},
		args = {"SinglePlayer"},
		run = function(realTask: Task.Class, args: {any})
			-- We use connections here to track memory instead of the janitor
			-- because this command was created before the switch to v2. I'll
			-- likely re-write a later date, but for now it cleansup memory
			-- safely and works as intended, so a lower priority
			local target: Player = unpack(args)
			local caller = realTask.caller
			if target == caller or not caller then
				Prompt.warn(caller, "Cannot control yourself!")
				return
			end
			local callerChar = caller.Character :: Model?
			local targetChar = target.Character :: Model?
			local janitor = realTask.janitor
			if not callerChar or not targetChar then
				return
			end
			realTask.client:run(target) -- This is necessary to activate the registering of the client module
			realTask.client:run(caller) -- Same here
			local function runControl()
				local callerChar = caller.Character
				if not callerChar then
					return
				end
				local targetChar = target.Character
				if not targetChar then
					return
				end
				local function clearPrevious(person)
					if person:GetAttribute("HDIsControlling") or person:GetAttribute("HDBeingControlledBy") then
						person:SetAttribute("HDIsControlling", nil)
						person:SetAttribute("HDBeingControlledBy", nil)
						realTask.wait(0.1)
					end
				end
				realTask:onEnded(function()
					target:SetAttribute("HDIsControlling", nil)
					target:SetAttribute("HDBeingControlledBy", nil)
				end)
				clearPrevious(target)
				clearPrevious(caller)
				caller:SetAttribute("HDIsControlling", target.Name)
				target:SetAttribute("HDBeingControlledBy", caller.Name)
				local function createClone(playerToClone: Player)
					--
					local input = playerToClone.Character
					if not input then
						return Instance.new("Model")
					end
					input.Archivable = true
					local clone = input:Clone()
					clone.Parent = workspace
					local animate = clone:FindFirstChild("Animate")
					local humanoid = clone:FindFirstChildOfClass("Humanoid")
					if animate and humanoid then
						for i,v: any in animate:GetChildren() do
							local anim = (v:GetChildren()[1])
							if anim and v.Name == "idle" then
								local track = humanoid:LoadAnimation(anim)
								track:Play()
							end
						end
					end
					return clone
					--]]
					--[[
					local humanoid = getHumanoid(playerToClone) or Instance.new("Humanoid")
					local desc = humanoid:GetAppliedDescription()
					local rig = Players:CreateHumanoidModelFromDescription(desc, humanoid.RigType)
					local char = target.Character
					local primaryPart = char and char.PrimaryPart
					if primaryPart then
						rig:SetPrimaryPartCFrame(primaryPart.CFrame)
					end
					rig.Name = target.Name
					return rig
					--]]
				end
				-- It's essential we parent in this exact order for animation scripts
				-- to work correctly
				local targetClone = createClone(target)
				local callerClone = createClone(caller)
				local sharedAssets = require(modules.References.sharedAssets)
				caller.Character = targetClone
				callerClone.Parent = sharedAssets
				targetClone.Parent = sharedAssets
				callerChar.Parent = sharedAssets
				targetChar.Parent = sharedAssets
				targetClone.Parent = workspace
				callerClone.Parent = workspace

				controlAction:fireClient(target, "BecomeControlled", true)
				controlAction:fireClient(target, "ViewPlayer", targetClone)
				local connections = {}
				local hasCleanedUp = false
				local function cleanup(dontKillTask: boolean?)
					if not hasCleanedUp then
						hasCleanedUp = true
						if caller.Parent then
							--[[local callerHRP = callerChar:FindFirstChild("HumanoidRootPart") :: BasePart?
							local targetHRP = targetClone:FindFirstChild("HumanoidRootPart") :: BasePart?
							if callerHRP and targetHRP then
								targetHRP.CFrame = callerHRP.CFrame
							end--]]
							caller:SetAttribute("HDIsControlling", nil)
							caller.Character = callerChar
							callerChar.Parent = workspace
							task.defer(function()
								--controlAction:fireClient(caller, "ViewPlayer", caller)
							end)
						else
							callerChar:Destroy()
						end
						if target.Parent then
							controlAction:fireClient(target, "SetResetButtonCallbackEnabled", true)
							target:SetAttribute("HDBeingControlledBy", nil)
							target.Character = targetChar
							targetChar.Parent = workspace
							controlAction:fireClient(target, "BecomeControlled", false)
							task.defer(function()
								controlAction:fireClient(target, "ViewPlayer", targetChar)
							end)
						else
							targetChar:Destroy()
						end
						targetClone:Destroy()
						callerClone:Destroy()
						for _, connection in connections do
							connection:Disconnect()
						end
					end
					if dontKillTask ~= true then
						realTask:destroy()
					end
				end
				realTask:onEnded(function()
					cleanup()
				end)
				controlAction:fireClient(target, "SetResetButtonCallbackEnabled", false)
				table.insert(connections, caller:GetAttributeChangedSignal("HDIsControlling"):Connect(cleanup))
				table.insert(connections, target:GetAttributeChangedSignal("HDBeingControlledBy"):Connect(cleanup))
				table.insert(connections, caller.AncestryChanged:Connect(function()
					if not caller.Parent then
						cleanup()
					end
				end))
				table.insert(connections, target.AncestryChanged:Connect(function()
					if not target.Parent then
						cleanup()
					end
				end))
				table.insert(connections, caller.CharacterAdded:Connect(function()
					cleanup()
				end))
				table.insert(connections, target.CharacterAdded:Connect(function()
					cleanup(true)
					task.delay(0.2, function()
						runControl()
					end)
				end))
			end
			realTask:keep("UntilCallerLeaves")
			realTask:keep("UntilTargetLeaves")
			runControl()
		end
	},

    --------------------
	{
		name = "Chat",
		aliases	= {"Talk", "Say", "Speak"},
		args = {"Player", "Text"},
		run = function(task: Task.Class, args: {any})
			local target, text = unpack(args)
			if text == "" or text == " " then
				text = "Example Chat Message"
			end
			local head = getHead(target)
			if head and #text > 0 then
				local forceChat = require(modules.ChatUtil.forceChat)
				forceChat(target, text)
			end
		end
	},
	
    --------------------
	
}


return commands