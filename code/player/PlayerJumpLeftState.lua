require "player.PlayerJumpState"

PlayerJumpLeftState = {}

function PlayerJumpLeftState:new()
	local state = PlayerJumpState:new("jumpLeft")

	state.superOnEnterState = state.onEnterState
	function state:onEnterState(event)
		local player = self.entity
		self:superOnEnterState(event)
		player:setDirection("left")
		player:showSprite("jump")
		self.xForce = -3
	end
	
	state.superOnExitState = state.onExitState
	function state:onExitState(event)
		local player = self.entity
		self:superOnExitState(event)
	end
	
	state.superTick = state.tick
	function state:tick(time)
		local player = self.entity
		player.x = player.x + self.xForce
		self:superTick(time)
	end
	
	return state
	
end

return PlayerJumpLeftState