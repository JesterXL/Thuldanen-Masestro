require "utils.BaseState"
SphereReadyState = {}

function SphereReadyState:new()
	local state = BaseState:new("ready")
	
	function state:onEnterState(event)
		print("Sphere ready state")
		local sphere = self.entity

		Runtime:addEventListener("Notes_onStopRoll", self)
		Runtime:addEventListener("Notes_onMoveRight", self)
		Runtime:addEventListener("Notes_onMoveLeft", self)
	end
	
	function state:onExitState(event)
		local sphere = self.entity

		Runtime:removeEventListener("Notes_onStopRoll", self)
		Runtime:removeEventListener("Notes_onMoveRight", self)
		Runtime:removeEventListener("Notes_onMoveLeft", self)
	end

	function state:Notes_onStopRoll()
		local sphere = self.entity
		sphere:stopRolling()
	end

	function state:Notes_onMoveRight()
		self.entity:startRollingRight()
	end

	function state:Notes_onMoveLeft()
		self.entity:startRollingLeft()
	end

	return state
end

return SphereReadyState