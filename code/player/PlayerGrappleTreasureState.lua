require "utils.BaseState"
PlayerGrappleTreasureState = {}

function PlayerGrappleTreasureState:new()
	local state = BaseState:new("grappleTreasure")
	state.startTime = nil
	state.END_TIME = 1 * 1000
	
	function state:onEnterState(event)
		print("grapple treasure state")
		local player = self.entity
		self.startTime = 0
		
		player:showSprite("stand")
		
		Runtime:addEventListener("onMovePlayerRightStarted", self)
		Runtime:addEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:addEventListener("onJumpPlayerRight", self)
		Runtime:addEventListener("onJumpPlayerLeft", self)
		Runtime:addEventListener("onAttackStarted", self)
	end
	
	function state:onExitState(event)
		local player = self.entity
		player:hideGrappleProgress()
		
		Runtime:removeEventListener("onMovePlayerRightStarted", self)
		Runtime:removeEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:removeEventListener("onJumpPlayerRight", self)
		Runtime:removeEventListener("onJumpPlayerLeft", self)
		Runtime:removeEventListener("onAttackStarted", self)
	end
	
	function state:tick(time)
		self.startTime = self.startTime + time
		local p = math.floor((self.startTime / self.END_TIME) * 100)
		self.entity:showGrappleProgress(p, 100)
		if self.startTime >= self.END_TIME then
			self.startTime = 0
			Runtime:dispatchEvent({name="onPlayerGrappledTreasureSuccessfully", target=self, player=self.entity})
			self.stateMachine:changeStateToAtNextTick("ready")
		end
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

	
	return state
end

return PlayerGrappleTreasureState