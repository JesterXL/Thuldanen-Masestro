require "utils.BaseState"

PlayerJumpLeftState = {}

function PlayerJumpLeftState:new()
	local state = BaseState:new("jumpLeft")
	state.timeout = 3 * 1000
	state.elapsedTime = nil

	function state:onEnterState(event)
		local player = self.entity
		player:setDirection("left")
		player:jumpLeft()
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

return PlayerJumpLeftState