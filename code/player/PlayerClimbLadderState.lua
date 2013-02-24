require "utils.BaseState"
PlayerClimbLadderState = {}

function PlayerClimbLadderState:new()
	local state = BaseState:new("climbLadder")
	
	function state:onEnterState(event)
		print("climb ladder")
		local player = self.entity
		
		player:showSprite("climb")
		
		Runtime:addEventListener("onMovePlayerRightStarted", self)
		Runtime:addEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:addEventListener("onJumpPlayerRight", self)
		Runtime:addEventListener("onJumpPlayerLeft", self)

		Runtime:addEventListener("onPlayerClimbUpStarted", self)
		Runtime:addEventListener("onPlayerClimbDownStarted", self)
		Runtime:addEventListener("onPlayerClimbUpEnded", self)
		Runtime:addEventListener("onPlayerClimbDownEnded", self)

		if player.climbDirection ~= nil then
			player:startClimbing()
		end
	end
	
	function state:onExitState(event)
		local player = self.entity
		player.climbDirection = nil
		player:stopClimbing()
		
		Runtime:removeEventListener("onMovePlayerRightStarted", self)
		Runtime:removeEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:removeEventListener("onJumpPlayerRight", self)
		Runtime:removeEventListener("onJumpPlayerLeft", self)

		Runtime:removeEventListener("onPlayerClimbUpStarted", self)
		Runtime:removeEventListener("onPlayerClimbDownStarted", self)
		Runtime:removeEventListener("onPlayerClimbUpEnded", self)
		Runtime:removeEventListener("onPlayerClimbDownEnded", self)
	end
	
	function state:tick(time)
		local player = self.entity
		if player.climbDirection == nil then
			return true
		end
		self:handleClimb(time)
	end
	
	function state:handleClimb(time)
		local player = self.entity
		local speed = player.climbSpeed
		if speed <= 0 then return true end


		local lastLadder = player.lastLadder
		if lastLadder == nil then
			return true
		end

		local ladderTop = (lastLadder.y - lastLadder.height / 2) - (player.height / 2)
		local ladderBottom = lastLadder.y + lastLadder.height / 2
		local targetX = player.x
		local targetY
		if player.climbDirection == "down" then
			targetY = player.y + speed
		elseif player.climbDirection == "up" then
			targetY = player.y - speed
		else
			targetY = 0
		end

		if targetY < ladderTop then
			player.y = ladderTop
			return true
		end

		print("targetY:", targetY, ", ladderBottom:", ladderBottom, ", player.y:", player.y, ", ladder.y:", lastLadder.y)
		if targetY + player.height > ladderBottom then
			player.y = ladderBottom - player.height
			return true
		end

		local deltaX = player.x - targetX
		local deltaY = player.y - targetY

		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
		print("dist:", dist)
		if dist == 0 then return true end
		local moveX = speed * (deltaX / dist) * time
		local moveY = speed * (deltaY / dist) * time

		--if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
		--	player.y = targetY
		--else
			player.y = player.y - moveY
		--end
	end
	
	function state:onPlayerClimbUpStarted(event)
		self.entity.climbDirection = "up"
	end

	function state:onPlayerClimbUpEnded(event)
		self.entity.climbDirection = nil
	end

	function state:onPlayerClimbDownStarted(event)
		self.entity.climbDirection = "down"
	end

	function state:onPlayerClimbDownEnded(event)
		self.entity.climbDirection = nil
	end


	function state:onMovePlayerLeftStarted(event)
		self.stateMachine:changeStateToAtNextTick("moveLeft")
	end
	
	function state:onMovePlayerRightStarted(event)
		self.stateMachine:changeStateToAtNextTick("moveRight")
	end
	
	function state:onJumpPlayerLeft(event)
		self.stateMachine:changeStateToAtNextTick("jumpLeft")
	end
	
	function state:onJumpPlayerRight(event)
		self.stateMachine:changeStateToAtNextTick("jumpRight")
	end

	
	return state
end

return PlayerClimbLadderState