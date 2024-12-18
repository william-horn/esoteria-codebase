--[[
	Author: William J. Horn
	Written: 10/26/2024
	
	Camera module for the game.
	This camera is attached to the player's character model and follows them around.
]]

return function(import, global, pm)
	local RunService = game:GetService("RunService")

	local packages = pm.from(script.Parent)

	local UserInputHandler = packages.import("UserInputHandler")
	local Math = import("Math")
	local props = import("@Util/@Objects/*")

	local Enums = game.ReplicatedStorage.Enums
	local CameraMode = Enums.CameraMode

	local playerMouse = UserInputHandler:getMouse()
	local rbxCamera = workspace.CurrentCamera


	--local characterModel = LocalPlayerManager:getCharacterModel()
	--local characterRootPart = characterModel:WaitForChild("HumanoidRootPart")

	-- defaults
	local CAMERA_PAN_MAX_RANGE = Vector2.new(70, 40) -- pan range fully zoomed out (40, 25)
	local CAMERA_PAN_MIN_RANGE = Vector2.new(10, 5) -- pan range fully zoomed in (10, 5)

	-- TODO: Make CAMERA_PAN_SPEED independant from camera zoom speed. there is currently no camera zoom speed setting, so this is used for both
	local CAMERA_PAN_SPEED = 0.07 -- default: 0.1

	local CAMERA_OFFSET_HEIGHT = 70 -- 35
	local CAMERA_OFFSET_RADIUS = 8 -- 8 -- TODO: handle case where radius = 0. For now this breaks because we can't get the direction
	local CAMERA_OFFSET_CENTER = Vector3.new(0, 0, 0)
	local CAMERA_ANGLE = math.pi/2

	local CAMERA_ZOOM_MIN = 0.1 -- (0.3) minimum zoom is this percentage*(CAMERA_OFFSET_HEIGHT, CAMERA_OFFSET_RADIUS)
	local CAMERA_ZOOM_INDEX = 3 -- current percentage zoomed in (from 0 to 1, with 0 being CAMERA_ZOOM_MIN)
	local CAMERA_ZOOM_SCROLLS = 10 -- 1/CAMERA_ZOOM_SCROLL increments

	local targetFocusObject = props.getBall(workspace)
	local originalTarget = props.getBall(workspace)
	originalTarget.BrickColor = BrickColor.Red()


	-- camera module
	local CustomCamera = {}

	CustomCamera.target = nil
	CustomCamera.mode = nil
	CustomCamera._lastFocusPosition = Vector3.new()
	CustomCamera._finalFocusPosition = Vector3.new()

	--CustomCamera.cameraFocus = props.getBall(workspace.World)

	-- override roblox's camera script which changes CameraType after this script loads
	-- TODO: look into finding a better solution to this
	-- this fails if something changes the CameraType property more than once before the GameClient is loaded
	--task.defer(function()
	--	rbxCamera.CameraType = Enum.CameraType.Scriptable
	--	rbxCamera:GetPropertyChangedSignal('CameraType'):Wait()
	--	rbxCamera.CameraType = Enum.CameraType.Scriptable
	--end)
	rbxCamera.CameraType = Enum.CameraType.Scriptable

	function CustomCamera:setTarget(target)
		self.target = target

		--[[
			TODO: add a hard set of the camera CFrame here, same as in playerCameraStep()
			where the CFrame should be set to the current position and the target's lookAt
			position. This is so we can set the camera angle immediately instead of having
			the camera rotating transition when the target is set or changed.
		]]
	end

	function CustomCamera:setMode(mode)
		if (not CameraMode[mode]) then
			error('Invalid CameraMode')
		end

		self.mode = mode
	end

	function CustomCamera:playerCameraStep()
		if (self.target == nil) then
			return
		end

		--[[
			n%b will reset after every `b` is reached
			(n%b)/b will reset after every `b` is reached, but it will take `b` duration to get from 0 to 1
		]]
		--CAMERA_ANGLE = (tick()%10)/10*(math.pi*2)
		originalTarget.CFrame = CFrame.new(self.target.Position)

		-- camera zoom settings
		local zoomMultiplier = math.clamp(
			CAMERA_ZOOM_INDEX/CAMERA_ZOOM_SCROLLS,
			0, 1
		)

		-- get the initial focus position (where the target is + a fixed offset from it)
		local initialTargetPosition = 
			self.target.Position + 
			CAMERA_OFFSET_CENTER

		-- find initial unit vector representing direction to and from point of origin
		local directionAway = Vector2.new(math.cos(CAMERA_ANGLE), math.sin(CAMERA_ANGLE))
		local directionTo = -directionAway

		--relative direction vectors (use cross product for left/right directions)
		-- `forward` is a direction only looking at the X and Z axes
		local forward = Vector3.new(directionTo.X, 0, directionTo.Y)
		--[[
			Since `forward` has no Y dimension, and is related to X and Z, we can
			create a new direction orthogonal to `forward` by adding a Y value of 1.
			Now that the original `forward` direction is vertically orthogonal to 
			`forward + Vector3.new(0, 1, 0)`, we can take the cross product of these
			vectors to compute the relative left and right directions.
		]]
		local left = (forward + Vector3.new(0, 1, 0)):Cross(forward)

		-- compute [-1/2, 1/2] values representing 2D mouse panning
		local offsetX = -(playerMouse.X/playerMouse.ViewSizeX - 0.5)
			*Math.lerp(CAMERA_PAN_MIN_RANGE.X, CAMERA_PAN_MAX_RANGE.X, zoomMultiplier)

		local offsetY = -(playerMouse.Y/playerMouse.ViewSizeY - 0.5)
			*Math.lerp(CAMERA_PAN_MIN_RANGE.Y, CAMERA_PAN_MAX_RANGE.Y, zoomMultiplier)

		-- where the focus position should exactly be
		local mousePanOffset = forward*offsetY + left*offsetX
		local finalTargetPosition = initialTargetPosition + mousePanOffset

		-- compute the incremental step of reaching `targetFocusPosition`
		local targetPositionStep = self._lastFocusPosition +
			(finalTargetPosition - self._lastFocusPosition)*CAMERA_PAN_SPEED

		-- update prop object
		targetFocusObject.CFrame = CFrame.new(finalTargetPosition)

		-- compute where the final camera position should be, from the finalTargetPosition
		local finalCameraPosition = finalTargetPosition + Vector3.new(
			directionAway.X*CAMERA_OFFSET_RADIUS,
			CAMERA_OFFSET_HEIGHT,
			directionAway.Y*CAMERA_OFFSET_RADIUS
		)*(zoomMultiplier + CAMERA_ZOOM_MIN) -- note: zoom will always be 1 + CAMERA_ZOOM_MIN of max camera height and radius, meaning it will be slightly further then what is set

		--[[
			we transition the camera position separately from the targetPositionStep position here
			so that we can change the camera position without changing where the targetPosition 
			should be. However, the `finalCameraPosition` is still based on the `finalTargetPosition`,
			so the two positions are still related.
		]]
		local cameraPositionStep = rbxCamera.CFrame.Position +
			(finalCameraPosition - rbxCamera.CFrame.Position)*CAMERA_PAN_SPEED

		-- updaate the camera position
		rbxCamera.CFrame = CFrame.lookAt(
			cameraPositionStep,
			targetPositionStep
		)

		-- update the last focused position
		self._lastFocusPosition = targetPositionStep
		self._finalTargetPosition = finalTargetPosition
	end

	local function cameraUpdateStep(step)
		if (CustomCamera.mode == CameraMode.Scriptable) then
			return

		elseif (CustomCamera.mode == CameraMode.PlayerCamera) then
			CustomCamera:playerCameraStep(step)
		end
	end

	function CustomCamera:listen()
		UserInputHandler:bindMouseWheelForward({
			handler = function()
				CAMERA_ZOOM_INDEX = math.max(CAMERA_ZOOM_INDEX - 1, 0)
			end
		})

		UserInputHandler:bindMouseWheelBackward({
			handler = function()
				CAMERA_ZOOM_INDEX = math.min(CAMERA_ZOOM_INDEX + 1, CAMERA_ZOOM_SCROLLS)
			end
		})

		task.spawn(function()
			RunService:BindToRenderStep(
				'CameraUpdate', 
				Enum.RenderPriority.Camera.Value, 
				cameraUpdateStep
			)
		end)

		return self
	end

	return {
		default = CustomCamera,
		CameraMode = CameraMode
	}
end
