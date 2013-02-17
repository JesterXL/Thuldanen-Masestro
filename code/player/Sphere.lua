require "utils.StateMachine"
require "player.SphereIdleState"
require "player.SphereReadyState"

Sphere = {}

function Sphere:new()
	local sphere = display.newCircle(0, 0, 30)
	mainGroup:insert(sphere)
	physics.addBody(sphere, "dynamic", {density=3, radius=30, bounce=0.2, friction=0.9})
	sphere.angularDamping = 5
	sphere.rollSpeed = 500
	sphere.rollDirection = "right"
	sphere.fsm = nil

	function sphere:init()
		self.fsm = StateMachine:new(self)
		self.fsm:addState2(SphereIdleState:new())
		self.fsm:addState2(SphereReadyState:new())
		self.fsm:setInitialState("ready")
	end

	function sphere:startRollingRight()
		self:stopRolling()
		self.direction = "right"
		Runtime:addEventListener("enterFrame", self)
	end

	function sphere:startRollingLeft()
		self:stopRolling()
		self.direction = "left"
		Runtime:addEventListener("enterFrame", self)
	end

	function sphere:rollRight()
		sphere:applyTorque(self.rollSpeed)
	end

	function sphere:rollLeft()
		sphere:applyTorque(-self.rollSpeed)
	end

	function sphere:stopRolling()
		Runtime:removeEventListener("enterFrame", self)
	end

	function sphere:touch(e)
		if e.phase == "began" then
			--Runtime:addEventListener("enterFrame", self)
		else
			--Runtime:removeEventListener("enterFrame", self)
			--sphere.angularVelocity = 0
		end
	end

	function sphere:enterFrame(e)
		if self.direction == "right" then
			self:rollRight()
		elseif self.direction == "left" then
			self:rollLeft()
		end
	end

	sphere:init()

	return sphere
end

return Sphere