require "utils.BaseState"
PlayerMoveState = {}

function PlayerMoveState:new(stateName)
	local state = BaseState:new(stateName)
	
	function state:onEnterState(event)
		print("move state")
		self.elapsedTime = 0

		Runtime:addEventListener("onMovePlayerRightEnded", self)
		Runtime:addEventListener("onMovePlayerLeftEnded", self)
	end
	
	function state:onExitState(event)
		Runtime:removeEventListener("onMovePlayerRightEnded", self)
		Runtime:removeEventListener("onMovePlayerLeftEnded", self)
		local player = self.entity
		player:stopMoving()

	end

	function state:onMovePlayerRightEnded(event)
		self.stateMachine:changeStateToAtNextTick("ready")
	end
	
	function state:onMovePlayerLeftEnded(event)
		self.stateMachine:changeStateToAtNextTick("ready")
	end
	
	function state:tick(time)
		self:handleMove(time)
	end
	
	function state:handleMove(time)
		local player = self.entity
		local speed = player.speed
		if speed <= 0 then return true end
		local targetX
		local targetY = player.y
		if player.direction == "right" then
			targetX = player.x + speed
		elseif player.direction == "left" then
			targetX = player.x - speed
		else
			targetX = 0
		end

		local deltaX = player.x - targetX
		local deltaY = player.y - targetY
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
		local moveX = speed * (deltaX / dist) * time
		local moveY = speed * (deltaY / dist) * time

		if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
			player.x = targetX
			player.y = targetY
		else
			player.x = player.x - moveX
			player.y = player.y - moveY
		end
	end
	
	return state
end

return PlayerMoveState