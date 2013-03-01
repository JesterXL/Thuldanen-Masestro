Treasure = {}

function Treasure:new()

	local box = display.newGroup()
	box.grappled = false -- indicates if a player has attached a chain/grapple to it
	box.player = nil
	box.speed = 0.1

	function box:init()
		mainGroup:insert(self)
		local boxImage = display.newImage("sprites/Treasure.png")
		box.boxImage = boxImage
		self:insert(boxImage)
		boxImage.x = 0
		boxImage.y = 0
		
		local treasurePhysicsData = (require "sprites.TreasurePhysicsData").physicsData(1.0)
		physics.addBody(self, "dynamic", treasurePhysicsData:get("treasure"))
		self.isFixedRotation = true
		self:addEventListener("touch", self)

		local disk = graphics.newImageSheet("sprites/treasure-disk-sheet.png", {width=240, height=160, numFrames=64})
		local sequenceData = 
		{
			{
				name="spin",
				start=1,
				count=64,
				time=2000,
			}
		}

		local diskSprite = display.newSprite(disk, sequenceData)
		self:insert(diskSprite)
		self.diskSprite = diskSprite
		diskSprite:setSequence("spin")
		diskSprite.isVisible = false
		diskSprite.y = boxImage.y + boxImage.height / 2 - 6
		diskSprite.x = diskSprite.x - 10
	end

	function box:touch(event)
		if event.phase == "ended" then
			if self.bodyType == "dynamic" then
				Runtime:dispatchEvent({name="onPlayerGrappleTreasure", target=self})
				return true
			else
				Runtime:dispatchEvent({name="onPlayerUnGrappleTreasure", target=self})
				return true
			end
		end
	end

	function box:activateLevitation(player)
		gameLoop:addLoop(self)
		self:addEventListener("collision", self)
		self.player = player
		self.bodyType = "kinematic"
		self.diskSprite.isVisible = true
		self.diskSprite:play()
	end

	function box:deactivateLevitation()
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", self)
		self.player = nil
		self.bodyType = "dynamic"
		self.diskSprite.isVisible = false
		self.diskSprite:pause()
	end

	function box:onCaptured()
		self.diskSprite:pause()
		self.isVisible = false
		local t = {}
		function t:timer()
			box.bodyType = "kinematic"
			box.x = -999
			box.y = -999
		end
		timer.performWithDelay(100, t)
		-- TODO: destroy
	end

	function box:tick(time)
		local player = self.player
		local deltaX = self.x - player.x
		local deltaY = self.y - (player.y - 60)

		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		if dist > 190 then
			self.speed = self.speed + 0.01
		elseif dist < 60 then
			if self.speed > 0.1 then
				self.speed = self.speed - 0.01
			end
		end

		local moveX = self.speed * (deltaX / dist) * time
		local moveY = self.speed * (deltaY / dist) * time

		self.x = self.x - moveX
		self.y = self.y - moveY
	end

	box:init()

	return box

end

return Treasure