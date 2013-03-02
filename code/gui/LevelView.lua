require "player.Sphere"
require "player.Player"
require "gui.PlayerControls"
require "sprites.Chain"
require "sprites.VerletChain"
require "gui.SideBar"
require "gui.SongBook"
require "gui.LevelCompletePopup"
require "gui.TreasureObtainedAnimation"

LevelView = {}

function LevelView:new()
	local level = display.newGroup()
	level.lastScrollTime = system.getTimer()
	level.sphere = nil
	level.player = nil
	level.scrollScreenTable = nil
	level.playerControls = nil
	level.sideBar = nil
	level.songBook = nil

	level.currentLevel = nil
	-- TODO: this could be a memory leak if the level is destroyed and this box hangs around
	level.lastGrappledTreasureBox = nil
	level.lastGrappleChain = nil
	level.sphereCollisionDelegate = nil
	level.portalEnabled = false

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

		self.sideBar = SideBar:new()
		self:insert(self.sideBar)

		Runtime:addEventListener("onPlayerEnterExitSphere", self)
		Runtime:addEventListener("onPlayerGrappleTreasure", self)
		Runtime:addEventListener("onPlayerGrappledTreasureSuccessfully", self)
		Runtime:addEventListener("onPlayerUnGrappleTreasure", self)
		Runtime:addEventListener("onSphereTouchedPortal", self)
		Runtime:addEventListener("onSongBookButtonTouched", self)
	end

	function level:loadLevel(levelRequirePath)
		if self.currentLevel then
			self.currentLevel:destroy()
			self.currentLevel = nil
		end
		local level = require(levelRequirePath):new()
		self.currentLevel = level
		level:build(self.sphere, self.player)
		self.sphere.x = level.sphereStartX
		self.sphere.y = level.sphereStartY

		if level.sphereStart == true then
			self.sphere:enable()
		else
			self.player:enable()
		end

		self:startScrollScreen()

		self:setPortalEnabled(false)
		self.playerControls.isVisible = true
		self.sideBar.isVisible = true
	end

	function level:scrollScreen()
		local w = stage.width
		local w2 = w / 2
		local player
		if self.player.enabled == true then
			player = self.player
		else
			player = self.sphere
		end
		local lastX = mainGroup.x
		local finalScrollX = math.min(0, w2 - player.x)
		finalScrollX = math.max(finalScrollX, -(mainGroup.width - stage.width - 20))
		mainGroup.x = finalScrollX
		self.currentLevel:move(mainGroup.x - lastX, 0)
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
				self:playerEnterSphere()
			end
		end
	end

	function level:onSphereTouched()
		if self.sphere.enabled then
			self:playerExitSphere()
		else
			self:onPlayerEnterExitSphere()
		end
	end

	function level:playerExitSphere()
		self.sphere:disable()
		self.player:enable()
		self.player.x = self.sphere.x
		self.player.y = self.sphere.y - self.sphere.height / 2 - 20
		self.playerControls.fsm:changeState("out")
	end

	function level:playerEnterSphere()
		self:onCapturedTreasureBox()
		self.player:disable()
		self.sphere:enable()
		self.playerControls.fsm:changeState("notes")
	end

	function level:onPlayerGrappleTreasure(event)
		self.lastGrappledTreasureBox = event.target
	end

	function level:onPlayerUnGrappleTreasure()
		self.lastGrappledTreasureBox:deactivateLevitation()
		self.lastGrappledTreasureBox = nil
		self.lastGrappleChain:destroy()
		self.lastGrappleChain = nil
		if self.sphereCollisionDelegate then
			self.sphere:removeEventListener("collision", self.sphereCollisionDelegate)
			self.sphereCollisionDelegate = nil
		end
	end

	function level:onPlayerGrappledTreasureSuccessfully(event)
		local player = event.player
		local treasureBox = self.lastGrappledTreasureBox
		assert(player ~= nil, "player must not be nil.")
		assert(treasureBox ~= nil, "treasureBox must not be nil.")
		self.lastGrappleChain = Chain:new(player, treasureBox)
		treasureBox:activateLevitation(player)
		local sphereCollisionDelegate = {}
		function sphereCollisionDelegate:collision(event)
			if event.other.classType == "Player" then
				level:onCapturedTreasureBox()
				return true
			end
		end
		self.sphereCollisionDelegate = sphereCollisionDelegate
		self.sphere:addEventListener("collision", sphereCollisionDelegate)
	end

	function level:onCapturedTreasureBox()
		local box = self.lastGrappledTreasureBox
		if box then
			self:onPlayerUnGrappleTreasure()
			box:onCaptured()
			TreasureObtainedAnimation:new()
			self:setPortalEnabled(true)
		end
	end

	function level:setPortalEnabled(enabled)
		self.portalEnabled = enabled
		if enabled then
			self.currentLevel:showPortal()
		else
			self.currentLevel:hidePortal()
		end
	end

	function level:onSphereTouchedPortal(event)
		self.sphere:disable()
		self.player:disable()
		self.playerControls.isVisible = false
		self.sideBar.isVisible = false
		local popup = LevelCompletePopup:new()
		popup:addEventListener("onNextLevelButtonTouched", self)
		self.popup = popup
	end

	function level:onSongBookButtonTouched(event)
		if self.songBook == nil then
			local book = SongBook:new()
			self:insert(book)
			book.fsm:setState("page1")
			self.songBook = book
			function book:touch(event)
				if event.phase == "ended" then
					level:onSongBookButtonTouched(event)
					return true
				end
			end
			book:addEventListener("touch", book)
			self.sideBar:toFront()
		else
			self.songBook:destroy()
			self.songBook = nil
		end
	end

	function level:onNextLevelButtonTouched(event)
		self.popup:removeEventListener("onNextLevelButtonTouched", self)
		self.popup:destroy()
		self.popup = nil
		self:dispatchEvent({name="onLoadNextLevel"})
	end

	level:init()

	return level
end

return LevelView