require "player.Sphere"
require "player.Player"
require "gui.PlayerControls"
require "sprites.Chain"
require "sprites.VerletChain"

LevelView = {}

function LevelView:new()
	local level = display.newGroup()
	level.lastScrollTime = system.getTimer()
	level.sphere = nil
	level.player = nil
	level.scrollScreenTable = nil
	level.playerControls = nil
	level.currentLevel = nil
	-- TODO: this could be a memory leak if the level is destroyed and this box hangs around
	level.lastGrappledTreasureBox = nil
	level.chains = {}

	function level:init()
		self.sphere = Sphere:new()
		self.player = Player:new()
		self.sphere:disable()
		self.player:disable()

		self.sphere:addEventListener("onSphereTouched", self)
		
		local scrollScreenTable = {}
		self.scrollScreenTable = scrollScreenTable
		function scrollScreenTable:enterFrame()
			level:scrollScreen()
		end

		self.playerControls = PlayerControls:new()
		self:insert(self.playerControls)

		Runtime:addEventListener("onPlayerEnterExitSphere", self)
		Runtime:addEventListener("onPlayerGrappleTreasure", self)
		Runtime:addEventListener("onPlayerGrappledTreasureSuccessfully", self)
	end

	function level:loadLevel(levelRequirePath)
		if self.currentLevel then
			self.currentLevel:destroy()
			self.currentLevel = nil
		end
		local level = require(levelRequirePath):new()
		self.currentLevel = level
		level:build()
		self.sphere.x = level.sphereStartX
		self.sphere.y = level.sphereStartY

		if level.sphereStart == true then
			self.sphere:enable()
		else
			self.player:enable()
		end

		self:startScrollScreen()
	end

	function level:scrollScreen()
		local w = mainGroup.width
		local centerX = w / 4
		local centerY = mainGroup.y
		local sphere
		if self.sphere.enabled == true then
			sphere = self.sphere
		else
			sphere = self.player
		end
		local playerX, playerY = sphere:localToContent(0, 0)
		local currentOffsetX = playerX - mainGroup.x
		local currentOffsetY = playerY - mainGroup.y
		local deltaX = playerX - centerX
		--local deltaY = playerY - centerY
		local deltaY = (-sphere.y) - mainGroup.y
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
		local speed = 0.15
		local passed = system.getTimer() - self.lastScrollTime
		self.lastScrollTime = system.getTimer()
		local moveX = speed * (deltaX / dist) * passed
		local moveY = speed * (deltaY / dist) * passed
		
		moveX = math.round(moveX)
		moveY = math.round(moveY)

		mainGroup.x = mainGroup.x - deltaX
		--mainGroup.y = -(sphere.y - 160)
	end	
	
	function level:startScrollScreen()
		Runtime:addEventListener("enterFrame", self.scrollScreenTable)
	end

	function level:stopScrollScreen()
		Runtime:removeEventListener("enterFrame", self.scrollScreenTable)
	end

	function level:onPlayerEnterExitSphere()
		if self.player.enabled == true then
			local dist = getDistance(self.player, self.sphere)
			if dist <= 143 then
				self.player:disable()
				self.sphere:enable()
				self.playerControls.fsm:changeState("notes")
			end
		end
	end

	function level:onSphereTouched()
		self.sphere:disable()
		self.player:enable()
		self.player.x = self.sphere.x
		self.player.y = self.sphere.y - self.sphere.height / 2 - 20
		self.playerControls.fsm:changeState("out")
	end

	function level:onPlayerGrappleTreasure(event)
		self.lastGrappledTreasureBox = event.target
	end

	function level:onPlayerGrappledTreasureSuccessfully(event)
		local player = event.player
		local treasureBox = self.lastGrappledTreasureBox
		assert(player ~= nil, "player must not be nil.")
		assert(treasureBox ~= nil, "treasureBox must not be nil.")
		--treasureBox.isSensor = true
		local chain = Chain:new(player, treasureBox)
		--local chain = VerletChain:new(player, treasureBox)

		treasureBox:activateLevitation(player)

		--[[
		print("------")
		local mappedX, mappedY = mainGroup:localToContent(player.x, player.y - player.height / 2)
		print(mappedX, mappedY)
		--mappedX, mappedY = mainGroup:contentToLocal(mappedX, mappedY)
		mappedX = mappedX + mainGroup.x
		print(mappedX, mappedY)
		print(player.x, player.y)
		print(treasureBox.x, treasureBox.y)
		local boxX, boxY = mainGroup:localToContent(treasureBox.x, treasureBox.y)
		boxX = boxX + mainGroup.x
		print(boxX, boxY)
		local rope = physics.newJoint("rope", treasureBox, player, boxX, boxY)
		
		--local rope = physics.newJoint("distance", player, treasureBox, player.x, player.y, treasureBox.x, treasureBox.y + treasureBox.height / 2)
		print("before:", rope.maxLength)
		rope.maxLength = 10
		print("after:", rope.maxLength)
		--rope.length = 50
		
		--rope = physics.newJoint("distance", player, treasureBox, player.x, player.y, treasureBox.x, treasureBox.y + treasureBox.height / 2)
		
		--treasureBox.bodyType = "kinematic"
		local mappedX, mappedY = mainGroup:localToContent(treasureBox.x, treasureBox.y)
		--mappedX = mappedX - mainGroup.x
		--local touchJoint = physics.newJoint( "touch", treasureBox, mappedX, mappedY)
		--mainGroup:insert(touchJoint)
		--touchJoint.frequency = 0.5
		---touchJoint.dampingRatio = 1
		--touchJoint.maxForce = 100

		local mappedX2, mappedY2 = mainGroup:localToContent(player.x, player.y)

		local distanceJoint = physics.newJoint("distance", player, treasureBox, mappedX2, mappedY2, mappedX, mappedY)
		distanceJoint.length = 40

		local t = {}
		t.x = treasureBox.x
		t.y = treasureBox.y
		function t:timer(time)
			local mappedX, mappedY = mainGroup:localToContent(player.x + player.width / 2, player.y)
			--print("------")
			--print("player:", player.x, player.y)
			--print("mapped:", mappedX, mappedY)
			--mappedX = mappedX + mainGroup.x
			touchJoint:setTarget( mappedX, mappedY )
			--print("a:", touchJoint:getAnchorA(), touchJoint:getAnchorB())
			print(touchJoint.anchorA)
		end
		--gameLoop:addLoop(t)
		--timer.performWithDelay(300, t, 0)
		]]--
	end

	level:init()

	return level
end

return LevelView