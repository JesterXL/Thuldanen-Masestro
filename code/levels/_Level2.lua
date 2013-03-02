require "physics"
require "sprites.Treasure"
--require "sprites.Ladder"
require "sprites.Portal"
local parallax = require( "utils.parallax" )

Level1 = {}

function Level1:new()

	local level = {}
	level.sphereStartX = 100
	level.sphereStartY = 420
	level.sphereStart = true
	level.treasures = {{x=2420, y=400}}
	--level.treasures = {{x=500, y=400}}
	level.treasureBoxes = {}
	level.parallaxScene = nil

	function level:build(sphere, player)
		self:destroy()

		local DIRECTORY_LEVEL = "levels/level2/"

		mainGroup:insert(sphere)
		mainGroup:insert(player)

		local portal = Portal:new()
		portal.x = self.sphereStartX + 20
		portal.y = self.sphereStartY + 20
		portal:hide()
		self.portal = portal

		print("getting data...")
		local level1PhysicsData = (require "levels.level2.level2").physicsData(1.0)
		local function getFloor(name, x, y)
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			--local nameSuffix = "-pretty.png"
			local nameSuffix = ".png"
			local floor = display.newImage(DIRECTORY_LEVEL .. name .. nameSuffix)
			floor.classType = "Floor"
			mainGroup:insert(floor)
			floor:setReferencePoint(display.TopLeftReferencePoint)
			floor.x = x
			floor.y = y
			physics.addBody(floor, "static", level1PhysicsData:get(name) )
			return floor
		end
		print("floor 1...")
		local floor1 = getFloor("floor-1")
		print("floor 2...")
		local floor2 = getFloor("floor-2")
		local floor3 = getFloor("floor-3")
		local floor4 = getFloor("floor-4")
		local floor5 = getFloor("floor-5")
		local floor6 = getFloor("floor-6")
		floor1.y = stage.height - (floor1.height + 80)

		floor2.x = floor1.x + floor1.width
		floor2.y = floor1.y + floor1.height - floor2.height
		floor2.x = floor2.x + 100
		floor2.y = floor2.y - 6

		floor3.x = floor2.x + floor2.width
		floor3.y = floor2.y + floor2.height - floor3.height
		--floor3.x = floor3.x - 120
		floor3.y = floor3.y + 3

		floor4.x = floor3.x + floor3.width - 2
		floor4.y = floor3.y + floor3.height - floor4.height


		floor5.x = floor4.x + floor4.width - 8
		floor5.y = floor4.y + floor4.height - floor5.height

		floor6.x = floor5.x + floor5.width - 8
		floor6.y = floor5.y + floor5.height - floor6.height

		self.floor1 = floor1
		self.floor2 = floor2
		self.floor3 = floor3
		self.floor4 = floor4
		self.floor5 = floor5
		self.floor6 = floor6

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

			physics.removeBody(self.floor1)
			physics.removeBody(self.floor2)
			physics.removeBody(self.floor3)
			physics.removeBody(self.floor4)
			physics.removeBody(self.floor5)
			physics.removeBody(self.floor6)

			self.floor1:removeSelf()
			self.floor2:removeSelf()
			self.floor3:removeSelf()
			self.floor4:removeSelf()
			self.floor5:removeSelf()
			self.floor6:removeSelf()
		end
	end

	function level:move(x, y)
		--self.parallaxScene:move(x, y)
	end

	function level:showPortal()
		self.portal:show()
	end

	function level:hidePortal()
		self.portal:hide()
	end

	return level

end

return Level1