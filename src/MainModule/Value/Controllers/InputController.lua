--!strict
-- CONFIG
local DRAG_INPUT = Enum.UserInputType.MouseMovement
local CLICK_INPUT = Enum.UserInputType.MouseButton1
local TOUCH_INPUT = Enum.UserInputType.Touch
local ARROW_KEYS = {[Enum.KeyCode.Left] = true, [Enum.KeyCode.Right] = true, [Enum.KeyCode.Up] = true, [Enum.KeyCode.Down] = true}
local MOVEMENT_KEYS = {[Enum.KeyCode.Left]="Left",[Enum.KeyCode.Right]="Right",[Enum.KeyCode.Up]="Forwards",[Enum.KeyCode.Down]="Backwards",[Enum.KeyCode.A]="Left",[Enum.KeyCode.D]="Right",[Enum.KeyCode.W]="Forwards",[Enum.KeyCode.S]="Backwards", [Enum.KeyCode.Space]="Up", [Enum.KeyCode.R]="Up", [Enum.KeyCode.Q]="Down", [Enum.KeyCode.LeftControl]="Down", [Enum.KeyCode.F]="Down"}


-- LOCAL
local InputController = {}
local isFocused = false
local isPressing = false
local lastHitPosition: Vector3 = Vector3.new(0,0)
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ChatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
local pressedMovementKeys = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Signal = require(modules.Objects.Signal)
local frameDragging: Frame? = nil
local onPressedCallbacks: {[Enum.KeyCode]: {any}} = {}
local createConnection = require(modules.AssetUtil.createConnection)


-- PUBLIC
InputController.pressed = Signal.new()


-- SETUP
-- Dictate if focused on another window (useful for chatting, cmdbar, etc)
UserInputService.TextBoxFocused:Connect(function()
	isFocused = true
end)
UserInputService.TextBoxFocusReleased:Connect(function()
	isFocused = false
end)
if ChatInputBarConfiguration then
	ChatInputBarConfiguration:GetPropertyChangedSignal("IsFocused"):Connect(function()
		isFocused = ChatInputBarConfiguration.IsFocused
	end)
end

-- Check to see if screen clicked/dragged/touched
local function checkPressFunctions(hitPosition)
	lastHitPosition = hitPosition
end
UserInputService.InputChanged:Connect(function(input, pressedUI)
	if not((input.UserInputType == DRAG_INPUT or input.UserInputType == TOUCH_INPUT) and (not pressedUI or frameDragging)) then
		return
	end
	if not isPressing then
		return
	end
	local difference = (lastHitPosition - input.Position)
	local distanceBetweenLastPos = difference.Magnitude
	if distanceBetweenLastPos >= 150 and UserInputService.TouchEnabled then --Prevent weird behavior with multiple touch inputs
		return
	end
	checkPressFunctions(input.Position)
end)
UserInputService.InputBegan:Connect(function(input: InputObject, pressedUI)
	local keyCode = input.KeyCode
	if (input.UserInputType == CLICK_INPUT or input.UserInputType == TOUCH_INPUT) and (not pressedUI or frameDragging) and not isPressing then
		isPressing = true
		checkPressFunctions(input.Position)
		InputController.pressed:Fire()
	elseif not isFocused then
		local direction = MOVEMENT_KEYS[keyCode]
		if direction then
			table.insert(pressedMovementKeys, direction)
		end
		local callbacksArray = onPressedCallbacks[keyCode]
		if callbacksArray then
			for _, callback in callbacksArray do
				callback(input)
			end
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, pressedUI)
	local direction = MOVEMENT_KEYS[input.KeyCode] 
	if input.UserInputType == CLICK_INPUT or input.UserInputType == TOUCH_INPUT then
		isPressing = false
	elseif direction then
		for i,v in pairs(pressedMovementKeys) do
			if v == direction then
				table.remove(pressedMovementKeys,i)
			end
		end
	end
end)


-- FUNCTIONS
function InputController.isFocused()
	return isFocused
end

function InputController.isPressing()
	return isPressing
end

function InputController.getLastHitPosition()
	return lastHitPosition
end

function InputController.getPressedMovementKeys()
	return pressedMovementKeys
end

function InputController.onPressed(keyCode: Enum.KeyCode, callback: (InputObject)->())
	local callbacksArray = onPressedCallbacks[keyCode]
	if not callbacksArray then
		callbacksArray = {}
		onPressedCallbacks[keyCode] = callbacksArray
	end
	table.insert(callbacksArray, callback)
	return createConnection(function()
		local index = table.find(callbacksArray, callback)
		if index then
			table.remove(callbacksArray, index)
		end
	end)
end

function InputController.onDoubleJumped(humanoid: Humanoid, callback: ()->())
	local jumps = 0
	local jumpDe = true
	local signal = humanoid:GetPropertyChangedSignal("Jump")
	local connection = signal:Connect(function()
		if jumpDe then
			jumpDe = false
			jumps = jumps + 1
			if jumps == 4 then
				callback()
			end
			task.wait()
			jumpDe = true
			task.wait(0.4)
			jumps = jumps - 1
		end
	end)
	return createConnection(function()
		connection:Disconnect()
	end)
end

function InputController.getHitPoint(rayLength: number?): (Vector3, Instance?)
	local camera = workspace.CurrentCamera
	local localPlayer = Players.LocalPlayer
	local char = localPlayer.Character
	local rayMag1 = camera:ScreenPointToRay(lastHitPosition.X, lastHitPosition.Y)
	local params = RaycastParams.new()
	if char then
   		params.FilterDescendantsInstances = {char}
    	params.FilterType = Enum.RaycastFilterType.Exclude
	end
	local origin = rayMag1.Origin
	local direction = rayMag1.Direction * (rayLength or 100)
    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Position, result.Instance
    end
	return origin + direction, nil
end


return InputController