require "physics"
require "sprites.Treasure"
require "sprites.Ladder"
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

		local DIRECTORY_LEVEL = "levels/level1/"

		-- NOTE: the width and height are larger; if not, the parallax shakes and bakes
		local scene = parallax.newScene(
			{
				width = 3000,
				height = 640,
				top=0,            -- So the bottom lines up with the bottom of the screen
				left = 0,
				bottom=635,
			    repeated = false         -- Optional, repeated defaults to false
			} 
		)

		local tites = scene:newLayer(
			{
				image = DIRECTORY_LEVEL .. "level1-parallax-2.png",
				width = 972,
				height = 244,
				top = 0,
				left=0,
				bott0m=244,
				speed=0.8,
				repeated="horizontal",
			}
		)

		scene:newLayer(
			{
				image = DIRECTORY_LEVEL .. "level1-parallax-1.png",
				width = 2637,
				height = 635,
				top = 0,
				left=0,
				speed=0.5,
				repeated=false,
			}
		)

		

		--mainGroup:insert(scene)
		scene:toBack()
		self.parallaxScene = scene

		local function getFloorBackground(name, x, y)
			local floor = display.newImage(DIRECTORY_LEVEL .. name .. "-pretty-background.png")
			mainGroup:insert(floor)
			floor:setReferencePoint(display.TopLeftReferencePoint)
			floor.x = x
			floor.y = y
			return floor
		end 

		local floor1bg = getFloorBackground("floor-1")
		local floor2bg = getFloorBackground("floor-2")
		local floor3bg = getFloorBackground("floor-3")
		local floor4bg = getFloorBackground("floor-4")



		mainGroup:insert(sphere)
		mainGroup:insert(player)

		local portal = Portal:new()
		portal.x = self.sphereStartX + 20
		portal.y = self.sphereStartY + 20
		portal:hide()
		self.portal = portal

		local level1PhysicsData = (require "levels.level1.level1").physicsData(1.0)
		local function getFloor(name, x, y)
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			local floor = display.newImage(DIRECTORY_LEVEL .. name .. "-pretty.png")
			floor.classType = "Floor"
			mainGroup:insert(floor)
			floor:setReferencePoint(display.TopLeftReferencePoint)
			floor.x = x
			floor.y = y
			physics.addBody(floor, "static", level1PhysicsData:get(name) )
			return floor
		end
		local floor1 = getFloor("floor-1")
		local floor2 = getFloor("floor-2")
		local floor3 = getFloor("floor-3")
		local floor4 = getFloor("floor-4")
		local floor5 = getFloor("floor-5")
		floor1.y = stage.height - (floor1.height + 80)

		floor2.x = floor1.x + floor1.width
		floor2.y = floor1.y + floor1.height - floor2.height
		floor2.x = floor2.x - 10

		floor3.x = floor2.x + floor2.width
		floor3.y = floor2.y + floor2.height - floor3.height
		floor3.x = floor3.x - 120
		floor3.y = floor3.y + 4

		floor4.x = floor3.x + floor3.width - 2
		floor4.y = floor3.y + floor3.height - floor4.height


		floor5.x = floor4.x + floor4.width - 8
		floor5.y = floor4.y + floor4.height - floor5.height

		floor1bg.x = 293
		floor1bg.y = 449

		floor2bg.x = floor2.x + 195
		floor2bg.y = floor2.x + 30

		floor3bg.x = floor3.x + 385
		floor3bg.y = floor3.y + 39

		floor4bg.x = floor4.x + 564
		floor4bg.y = floor4.y + 104

		function floor3:preCollision(event)
			if event.other.classType == "Player" then
				if event.other.climbing == true then
					event.contact.isEnabled = false
				end
			end
		end
		floor3:addEventListener("preCollision", floor3)

		self.floor1 = floor1
		self.floor2 = floor2
		self.floor3 = floor3
		self.floor4 = floor4
		self.floor5 = floor5

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
		--local floor3Depth = table.indexOf(mainGroup, floor3)
		ladder:toBack()
		ladder.x = floor3.x + ladder.width
		ladder.y = 360

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

			self.floor3:removeEventListener("preCollision", self.floor3)
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

	function level:move(x, y)
		self.parallaxScene:move(x, y)
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