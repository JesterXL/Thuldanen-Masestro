require "utils.StateMachine"
require "player.SphereIdleState"
require "player.SphereReadyState"

Sphere = {}

function Sphere:new()
	local sphere = display.newCircle(0, 0, 30)
	mainGroup:insert(sphere)
	physics.addBody(sphere, "dynamic", {density=3, radius=30, bounce=0.2, friction=0.9})
	sphere.angularDamping = 5
	sphere.rollSpeed = 300
	sphere.rollDirection = "right"
	sphere.fsm = nil
	sphere.enabled = true

	function sphere:init()
		self.fsm = StateMachine:new(self)
		self.fsm:addState2(SphereIdleState:new())
		self.fsm:addState2(SphereReadyState:new())
		self.fsm:setInitialState("ready")

		self:addEventListener("touch", self)
	end

	function sphere:enable()
		if self.enabled == false then
			self.enabled = true
			gameLoop:addLoop(self.fsm)
			self.fsm:changeState("ready")
		end
	end

	function sphere:disable()
		if self.enabled == true then
			self.enabled = false
			self.fsm:changeState("idle")
			gameLoop:removeLoop(self.fsm)
		end
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

	function sphere:jumpRight()
		print("sphere jump right")
		self:applyLinearImpulse(60, 300, sphere.x, sphere.y)
	end

	function sphere:jumpLeft()
		print("sphere jump left")
		self:applyLinearImpulse(-60, 300, sphere.x, sphere.y)
	end

	function sphere:enterFrame(e)
		if self.direction == "right" then
			self:rollRight()
		elseif self.direction == "left" then
			self:rollLeft()
		end
	end

	function sphere:touch(e)
		if e.phase == "ended" then
			self:dispatchEvent({name="onSphereTouched", target=self})
			return true
		end
	end

	sphere:init()

	return sphere
end

return Sphere