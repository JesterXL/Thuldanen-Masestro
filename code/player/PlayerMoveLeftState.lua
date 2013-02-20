require "player.PlayerMoveState"

PlayerMoveLeftState = {}

function PlayerMoveLeftState:new()
	local state = PlayerMoveState:new("moveLeft")
	
	state.superOnEnterState = state.onEnterState
	function state:onEnterState(event)
		self:superOnEnterState(event)
		self.entity:setDirection("left")
		self.entity:showSprite("move")
	end
	
	return state
end

return PlayerMoveLeftState