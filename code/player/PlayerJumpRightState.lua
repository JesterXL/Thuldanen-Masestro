require "utils.BaseState"

PlayerJumpRightState = {}

function PlayerJumpRightState:new()
	local state = BaseState:new("jumpRight")
	state.timeout = 3 * 1000
	state.elapsedTime = nil

	function state:onEnterState(event)
		local player = self.entity
		player:setDirection("right")
		player:jumpRight()
		player:showSprite("jump")
		self.elapsedTime = 0
	end
	
	function state:onExitState(event)
		local player = self.entity
	end
	
	function state:tick(time)
		self.elapsedTime = self.elapsedTime + time
		if self.elapsedTime >= self.timeout then
			local player = self.entity
			self.stateMachine:changeStateToAtNextTick("ready")
		end
	end
	
	return state
	
end

return PlayerJumpRightState