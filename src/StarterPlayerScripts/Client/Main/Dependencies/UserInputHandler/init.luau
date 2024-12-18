--[[
	@author: 
		William J. Horn
		ScriptGuider @ROBLOX.com
		
	@written:
		05/23/2021
		
	@description:
		The UserInputHandler module gives the developer more convenient control over handling user input. It also
		utilizes the CustomEvent API, so it includes features such as event bubbling, toggling events,
		event dispatch validation, etc.
		
		Note: This program was designed to run in the ROBLOX environment with ROBLOX's modified version of Lua.
		
	@last-updated:
		07/16/2023
		
	@help:
		If you have any questions or concerns, please email me at: williamjosephhorn@gmail.com
]]

return function(import, global, pm)
	-----------------------
	--- ROBLOX services ---
	-----------------------
	local PlayerService = game:GetService("Players")
	local InputService = game:GetService("UserInputService")


	---------------
	--- Imports ---
	---------------
	local server = pm.from(script.Parent.Parent)

	local Event = import("EventSignal")

	local Package__Aliases = require(script.Aliases)
	local DeviceType, MouseWheelType = Package__Aliases.DeviceType, Package__Aliases.MouseWheelType

	---

	local PlayerMouse = PlayerService.LocalPlayer:GetMouse()
	PlayerMouse.TargetFilter = workspace:WaitForChild('World')

	----------------------------
	--- User input interface ---
	----------------------------
	local UserInput = {
		devices = Event.new({
			name = "InputEvent",
			settings = {
				requiresConnection = false
			}
		})
	}

	UserInput.devices.keyboard = Event.new({
		name = "KeyboardEvent",
		parent = UserInput.devices,
		settings = {
			dispatchAscendants = true,
			requiresConnection = false
		}
	})

	UserInput.devices.mouse = Event.new({
		name = "MouseEvent",
		parent = UserInput.devices,
		settings = {
			dispatchAscendants = true,
			requiresConnection = false
		}
	})

	-------------------------
	--- Utility functions ---
	-------------------------
	local function getInputEvent(deviceType, input, state)
		local device = UserInput.devices[deviceType]
		local eventMaster = device.scope[input]

		if (not eventMaster) then
			-- input event 
			eventMaster = Event.new({
				name = "InputNode",
				parent = device,
				settings = {
					dispatchAscendants = true,
					requiresConnection = false
				}
			})

			-- input state event
			eventMaster.scope[state] = Event.new({ 
				name = "StateType", 
				parent = eventMaster,
				settings = {
					dispatchAscendants = true
				}
			})

			device.scope[input] = eventMaster

		elseif (not eventMaster.scope[state]) then
			eventMaster.scope[state] = Event.new({
				name = "StateType",
				parent = eventMaster,
				settings = {
					dispatchAscendants = true
				}
			})
		end

		return eventMaster.scope[state]
	end

	local function bindInputEvent(deviceType, input, state, connectOptions)
		local event = getInputEvent(deviceType, input, state)
		local connection = event:connect(connectOptions)
		return event, connection 
	end

	local function unbindInputEvent(deviceType, input, state, disconnectOptions)
		local event = UserInput.devices[deviceType].scope[input]

		if (event and event.scope[state]) then
			event.scope[state]:disconnect(disconnectOptions)
		end
	end

	local function fireInputEvent(deviceType, inputType, state, ...)
		if (deviceType == DeviceType.Master) then
			UserInput.devices:fire(inputType, ...) 
			return
		end

		local device = UserInput.devices[deviceType]
		local event = device.scope[inputType] 

		if (event and event.scope[state]) then
			event.scope[state]:fire(inputType, ...)
		else
			UserInput.devices[deviceType]:fire(inputType, ...)
		end
	end

	local function waitForInputEvent(deviceType, input, state, timeout)
		local event = getInputEvent(deviceType, input, state)
		return event:wait(timeout)
	end

	----------------------
	--- User input API ---
	----------------------

	function UserInput:getMouse()
		return PlayerMouse
	end

	function UserInput:getMouseHit()
		return PlayerMouse.Hit
	end

	function UserInput:getMousePosition()
		return Vector2.new(PlayerMouse.X, PlayerMouse.Y)
	end

	function UserInput:getScreenSize()
		return workspace.CurrentCamera.ViewportSize
	end

	--- Bind directly to devices ---
	function UserInput:bindInput(connectOptions)
		self.devices:connect(connectOptions)
	end

	function UserInput:bindMouse(connectOptions)
		self.devices.mouse:connect(connectOptions)
	end

	function UserInput:bindKeyboard(connectOptions)
		self.devices.keyboard:connect(connectOptions) 
	end



	--- Bind to keyboard API ---
	function UserInput:bindKeyDown(keyCode, connectOptions)
		return bindInputEvent(DeviceType.Keyboard, keyCode, Enum.UserInputState.Begin, connectOptions)
	end

	function UserInput:bindKeyUp(keyCode, connectOptions)
		return bindInputEvent(DeviceType.Keyboard, keyCode, Enum.UserInputState.End, connectOptions)
	end

	--- Unbind from keyboard API ---
	function UserInput:unbindKeyDown(keyCode, connectOptions)
		unbindInputEvent(DeviceType.Keyboard, keyCode, Enum.UserInputState.Begin, connectOptions)
	end

	function UserInput:unbindKeyUp(keyCode, connectOptions)
		unbindInputEvent(DeviceType.Keyboard, keyCode, Enum.UserInputState.End, connectOptions)
	end

	--- Wait for key input API ---
	function UserInput:waitForKeyDown(keyCode, timeout)
		return waitForInputEvent(DeviceType.Keyboard, keyCode, Enum.UserInputState.Begin, timeout)
	end

	function UserInput:waitForKeyUp(keyCode, timeout)
		return waitForInputEvent(DeviceType.Keyboard, keyCode, Enum.UserInputState.End, timeout)
	end


	function UserInput:bindMouseWheelForward(connectOptions)
		return bindInputEvent(DeviceType.Mouse, Enum.UserInputType.MouseWheel, MouseWheelType.Forward, connectOptions)
	end

	function UserInput:bindMouseWheelBackward(connectOptions)
		return bindInputEvent(DeviceType.Mouse, Enum.UserInputType.MouseWheel, MouseWheelType.Backward, connectOptions)
	end


	function UserInput:bindMouse1Down(connectOptions)
		return bindInputEvent(DeviceType.Mouse, Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, connectOptions)
	end

	function UserInput:bindMouse1Up(connectOptions)
		return bindInputEvent(DeviceType.Mouse, Enum.UserInputType.MouseButton1, Enum.UserInputState.End, connectOptions)
	end

	function UserInput:bindMouseMovement(connectOptions)
		return bindInputEvent(DeviceType.Mouse, Enum.UserInputType.MouseMovement, Enum.UserInputState.Change, connectOptions)
	end

	function UserInput:unbindMouseMovement(connectOptions)
		return unbindInputEvent(DeviceType.Mouse, Enum.UserInputType.MouseMovement, Enum.UserInputState.Change, connectOptions)
	end

	---------------------------
	--- User input handlers ---
	---------------------------
	local function handleInputState(inputObj, gameProcessed)
		local inputType = inputObj.UserInputType
		local inputState = inputObj.UserInputState
		local keyCode = inputObj.KeyCode

		-- keyboard
		if (inputType == Enum.UserInputType.Keyboard) then
			fireInputEvent(DeviceType.Keyboard, keyCode, inputState, inputObj, gameProcessed)

			-- mouse
		elseif (inputType.Value <= 3) then
			fireInputEvent(DeviceType.Mouse, inputType, inputState, inputObj, gameProcessed)

			-- other
		else
			fireInputEvent(DeviceType.Master, inputType, inputState, inputObj, gameProcessed)
		end
	end

	local function handleInputChanged(inputObj, gameProcessed)
		local inputType = inputObj.UserInputType
		local inputState = inputObj.UserInputState

		-- Mouse movement
		if inputType.Value == 4 then
			fireInputEvent(DeviceType.Mouse, inputType, inputState, inputObj.Position, gameProcessed)

			-- Mouse wheel
		elseif inputType.Value == 3 then

			if inputObj.Position.Z >= 0.5 then
				fireInputEvent(DeviceType.Mouse, inputType, MouseWheelType.Forward, gameProcessed)

			elseif inputObj.Position.Z <= 0.5 then
				fireInputEvent(DeviceType.Mouse, inputType, MouseWheelType.Backward, gameProcessed)
			end

		end

	end

	----------------------------------
	--- Event listener connections ---
	----------------------------------
	function UserInput:init()
		InputService.InputBegan:Connect(handleInputState)
		InputService.InputEnded:Connect(handleInputState)
		InputService.InputChanged:Connect(handleInputChanged)

		return self
	end

	return {
		default = UserInput
	}
end
