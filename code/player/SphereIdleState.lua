require "utils.BaseState"
SphereIdleState = {}

function SphereIdleState:new()
	local state = BaseState:new("idle")
	
	function state:onEnterState(event)
		print("Sphere idle state")
		local sphere = self.entity
	end
	
	function state:onExitState(event)
		local sphere = self.entity
	end

	return state
end

return SphereIdleState