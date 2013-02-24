require "utils.BaseState"
PlayerReadyState = {}

function PlayerReadyState:new()
	local state = BaseState:new("ready")
	
	function state:onEnterState(event)
		print("ready state")
		local player = self.entity
		--print("player.x:", player.x)
		player:showSprite("stand")
		
		Runtime:addEventListener("onMovePlayerRightStarted", self)
		Runtime:addEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:addEventListener("onJumpPlayerRight", self)
		Runtime:addEventListener("onJumpPlayerLeft", self)
		Runtime:addEventListener("onAttackStarted", self)
		Runtime:addEventListener("onPlayerClimbUpStarted", self)
		Runtime:addEventListener("onPlayerClimbDownStarted", self)

		Runtime:addEventListener("onPlayerGrappleTreasure", self)
	end
	
	function state:onExitState(event)
		local player = self.entity
		
		Runtime:removeEventListener("onMovePlayerRightStarted", self)
		Runtime:removeEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:removeEventListener("onJumpPlayerRight", self)
		Runtime:removeEventListener("onJumpPlayerLeft", self)
		Runtime:removeEventListener("onAttackStarted", self)
		Runtime:removeEventListener("onPlayerClimbUpStarted", self)
		Runtime:removeEventListener("onPlayerClimbDownStarted", self)

		Runtime:removeEventListener("onPlayerGrappleTreasure", self)
	end
	
	function state:tick(time)
		local player = self.entity
	end
	
	function state:onMovePlayerLeftStarted(event)
		self.stateMachine:changeStateToAtNextTick("moveLeft")
	end
	
	function state:onMovePlayerRightStarted(event)
		self.stateMachine:changeStateToAtNextTick("moveRight")
	end
	
	function state:onAttackStarted(event)
		self.stateMachine:changeStateToAtNextTick("attack")
	end
	
	function state:onJumpPlayerLeft(event)
		self.stateMachine:changeStateToAtNextTick("jumpLeft")
	end
	
	function state:onJumpPlayerRight(event)
		self.stateMachine:changeStateToAtNextTick("jumpRight")
	end

	function state:onPlayerGrappleTreasure(event)
		local dist = getDistance(self.entity, event.target)
		if dist < 69 then
			self.stateMachine:changeStateToAtNextTick("grappleTreasure")
		end
	end

	function state:onPlayerClimbUpStarted(event)
		self.entity.climbDirection = "up"
		self.stateMachine:changeStateToAtNextTick("climbLadder")
	end

	function state:onPlayerClimbDownStarted(event)
		self.entity.climbDirection = "down"
		self.stateMachine:changeStateToAtNextTick("climbLadder")
	end
	
	return state
end

return PlayerReadyState