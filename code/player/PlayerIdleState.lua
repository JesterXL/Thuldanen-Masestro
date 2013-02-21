require "utils.BaseState"
PlayerIdleState = {}

function PlayerIdleState:new()
	local state = BaseState:new("idle")
	
	function state:onEnterState(event)
		local player = self.entity
	end
	
	function state:onExitState(event)
		local player = self.entity
	end
	
	return state
end

return PlayerIdleState