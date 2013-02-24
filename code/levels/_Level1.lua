require "physics"
require "sprites.Treasure"
require "sprites.Ladder"

Level1 = {}

function Level1:new()

	local level = {}
	level.sphereStartX = 100
	level.sphereStartY = 420
	level.sphereStart = true
	level.treasures = {{x=2420, y=400}}
	level.treasureBoxes = {}

	function level:build()
		self:destroy()

		local level1PhysicsData = (require "levels.level1.level1").physicsData(1.0)
		local function getFloor(name, x, y)
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			local floor = display.newImage("levels/level1/" .. name .. ".png")
			floor.classType = "Floor"
			mainGroup:insert(floor)
			floor:setReferencePoint(display.TopLeftReferencePoint)
			floor.x = x
			floor.y = y
			physics.addBody(floor, "static", level1PhysicsData:get(name) )
			return floor
		end
		local floor1 = getFloor("floor-1")
		local floor2 = getFloor("floor-2", 0, 0)
		local floor3 = getFloor("floor-3", 0, 0)
		local floor4 = getFloor("floor-4", 0, 0)
		local floor5 = getFloor("floor-5")
		floor1.y = stage.height - (floor1.height + 80)
		floor2.x = floor1.x + floor1.width
		floor2.y = floor1.y + floor1.height - floor2.height
		floor4.x = floor2.x + floor2.width
		floor4.x = floor4.x - 60
		floor4.y = floor2.y + floor2.height - floor4.height
		floor5.x = floor4.x + floor4.width
		floor5.y = floor4.y + floor4.height - floor5.height
		floor3.x = floor5.x + floor5.width
		floor3.y = floor5.y + floor5.height - floor3.height

		function floor4:preCollision(event)
			if event.other.classType == "Player" then
				if event.other.climbing == true then
					event.contact.isEnabled = false
				end
			end
		end
		floor4:addEventListener("preCollision", floor4)

		self.floor1 = floor1
		self.floor2 = floor2
		self.floor3 = floor3
		self.floor4 = floor4

		local treasureBoxes = self.treasures
		local i = 1
		local len = table.maxn(treasureBoxes)
		for i=1,len do
			local boxSpot = treasureBoxes[i]
			local box = Treasure:new()
			table.insert(treasureBoxes, box)
			box.x = boxSpot.x
			box.y = boxSpot.y
		end

		local ladder = Ladder:new()
		ladder.x = floor4.x
		ladder.y = 400

	end

	function level:destroy()
		if self.floor1 then

			local len = table.maxn(self.treasureBoxes)
			local i
			for i=len,1,-1 do
				local box = self.treasureBoxes[i]
				box:destroy()
				table.remove(self.treasureBoxes, i)
			end

			self.floor4:removeEventListener("preColli", self.floor4)
			-- TODO: safe remove
			physics.removeBody(self.floor1)
			physics.removeBody(self.floor2)
			physics.removeBody(self.floor3)
			physics.removeBody(self.floor4)
			physics.removeBody(self.floor5)

			self.floor1:removeSelf()
			self.floor2:removeSelf()
			self.floor3:removeSelf()
			self.floor4:removeSelf()
			self.floor5:removeSelf()
		end
	end

	return level

end

return Level1