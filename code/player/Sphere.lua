Sphere = {}

function Sphere:new()
	local sphere = display.newCircle(0, 0, 10)
	mainGroup:insert(sphere)
	physics.addBody(sphere, "dynamic", {density=3, radius=30, bounce=0.2, friction=0.9})
	sphere.angularDamping = 5
	sphere.rollSpeed = 500

	function sphere:rollRight()
		sphere:applyTorque(self.rollSpeed)
	end

	function sphere:rollLeft()
		sphere:applyTorque(-self.rollSpeed)
	end

	function sphere:touch(e)
		if e.phase == "began" then
			Runtime:addEventListener("enterFrame", self)
		else
			Runtime:removeEventListener("enterFrame", self)
			--sphere.angularVelocity = 0
		end
	end

	function sphere:enterFrame()
		self:rollRight()
	end

	Runtime:addEventListener("touch", sphere)
		

	return sphere
end

return Sphere