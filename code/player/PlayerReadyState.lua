require "utils.BaseState"
PlayerReadyState = {}

function PlayerReadyState:new()
	local state = BaseState:new("ready")
	
	function state:onEnterState(event)
		print("ready state")
		local player = self.entity
		
		player:showSprite("stand")
		
		Runtime:addEventListener("onMovePlayerRightStarted", self)
		Runtime:addEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:addEventListener("onJumpPlayerRightStarted", self)
		Runtime:addEventListener("onJumpPlayerLeftStarted", self)
		Runtime:addEventListener("onAttackStarted", self)
	end
	
	function state:onExitState(event)
		local player = self.entity
		
		Runtime:removeEventListener("onMovePlayerRightStarted", self)
		Runtime:removeEventListener("onMovePlayerLeftStarted", self)
		
		Runtime:removeEventListener("onJumpPlayerRightStarted", self)
		Runtime:removeEventListener("onJumpPlayerLeftStarted", self)
		Runtime:removeEventListener("onAttackStarted", self)
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
	
	function state:onJumpLeftStarted(event)
		self.stateMachine:changeStateToAtNextTick("jumpLeft")
	end
	
	function state:onJumpRightStarted(event)
		self.stateMachine:changeStateToAtNextTick("jumpRight")
	end
	
	return state
end

return PlayerReadyState