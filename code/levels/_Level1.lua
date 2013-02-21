require "physics"

Level1 = {}

function Level1:new()

	local level = {}
	level.sphereStartX = 100
	level.sphereStartY = 100
	level.sphereStart = true

	function level:build()
		self:destroy()

		local level1PhysicsData = (require "levels.level1").physicsData(1.0)
		local function getFloor(name, x, y)
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			local floor = display.newImage("levels/level1/" .. name .. ".png")
			mainGroup:insert(floor)
			floor:setReferencePoint(display.TopLeftReferencePoint)
			floor.x = x
			floor.y = y
			physics.addBody(floor, "static", level1PhysicsData:get(name) )
			return floor
		end
		local floor1 = getFloor("floor-1", 0, 0)
		local floor2 = getFloor("floor-2")
		local floor3 = getFloor("floor-3")
		floor1.y = stage.height - (floor1.height + 80)
		floor2.x = floor1.x + floor1.width
		floor2.y = floor1.y + floor1.height - floor2.height
		floor3.x = floor2.x + floor2.width
		floor3.y = floor2.y + floor2.height - floor3.height
		self.floor1 = floor1
		self.floor2 = floor2
		self.floor3 = floor3
	end

	function level:destroy()
		if self.floor1 then
			-- TODO: safe remove
			physics.removeBody(self.floor1)
			physics.removeBody(self.floor2)
			physics.removeBody(self.floor3)

			self.floor1:removeSelf()
			self.floor2:removeSelf()
			self.floor3:removeSelf()

		end
	end

	return level

end

return Level1