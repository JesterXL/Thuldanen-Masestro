require "utils.BaseState"
SphereIdleState = {}

function SphereIdleState:new()
	local state = BaseState:new("idle")
	
	function state:onEnterState(event)
		print("Sphere idle state")
		local sphere = self.entity
		sphere:showSprite("doorOpen")
		sphere:stopRolling()
	end
	
	function state:onExitState(event)
		local sphere = self.entity
		sphere:showSprite("doorClose")
	end

	return state
end

return SphereIdleState