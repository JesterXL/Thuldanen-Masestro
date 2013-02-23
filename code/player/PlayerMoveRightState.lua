require "player.PlayerMoveState"

PlayerMoveRightState = {}

function PlayerMoveRightState:new()
	local state = PlayerMoveState:new("moveRight")
	
	state.superOnEnterState = state.onEnterState
	function state:onEnterState(event)
		self:superOnEnterState(event)
		self.entity:setDirection("right")
		self.entity:showSprite("move")
	end
	
	return state
end

return PlayerMoveRightState