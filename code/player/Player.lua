require "utils.StateMachine"
require "player.PlayerJumpLeftState"
require "player.PlayerJumpRightState"
require "player.PlayerMoveLeftState"
require "player.PlayerMoveRightState"
require "player.PlayerIdleState"
require "player.PlayerReadyState"
require "player.PlayerGrappleTreasureState"
require "player.PlayerClimbLadderState"
require "gui.ProgressBar"

Player = {}

function Player:new()
	local player = display.newGroup()
	player.classType = "Player"
	mainGroup:insert(player)
	player.direction = "right"
	
	player.speed = 4
	player.climbSpeed = 0.1
	player.health = 40

	player.moving = false
	player.jumping = false
	player.climbing = false
	player.climbDirection = nil
	player.jumpXForce = 4
	player.jumpYForce = 6

	player.fsm = nil
	player.enabled = true
	player.grappleProgressBar = nil
	player.lastLadder = nil

	function player:init()
		self.spriteHolder = display.newGroup()
		self:insert(self.spriteHolder)

		local sheet = graphics.newImageSheet("player/Player-sheet.png", {width=64, height=64, numFrames=18})
		local sequenceData = 
		{
			{
				name="stand",
				start=1,
				count=3,
				time=1000,
				loopDirection="bounce"
			},
			{
				name="move",
				frames={1, 4, 5},
				time=600,
			},
			{
				name="defend",
				start=7,
				count=1,
				time=5000,
			},
			{
				name="attack",
				frames={8, 9, 10, 11, 12, 13, 14},
				time=500
			}
		}

		local sprite = display.newSprite(sheet, sequenceData)
		sprite:setSequence("stand")
		sprite:play()
		self.sheet = sheet
		self.sequenceData = sequenceData
		self.sprite = sprite
		self.spriteHolder:insert(self.sprite)
		sprite.x = 11
		sprite.y = 8

		-- regular physics
		physics.addBody(self, "dynamic", {density=0.3, friction=0.8, bounce=0.2, 
											shape={0,0, 20,0, 20,40, 0,40}})
		self.isFixedRotation = true

		--[[
		-- let's try a wheel
		local rect = display.newRect(0, 0, 20, 40)
		self:insert(rect)
		rect.x = 0
		rect.y = 0
		physics.addBody(rect, "dynamic", {density=0.3, friction=0.8, bounce=0.2, 
											shape={0,0, 20,0, 20,40, 0,40} })
		rect.isFixedRotation = true

		local circle = display.newCircle(0, 0, 10)
		self:insert(circle)
		circle.x = 0
		circle.y = rect.y + rect.height / 2
		physics.addBody(circle, "dynamic", {density=0.3, friction=0.8, bounce=0.2} )
		


		local wheelJoint = physics.newJoint("wheel", 
														rect, circle,
														rect.x, rect.y,
														0, 0)
		wheelJoint.isMotorEnabled = true
		wheelJoint.motorSpeed = 0
		]]--

		self.fsm = StateMachine:new(self)
		self.fsm:addState2(PlayerJumpLeftState:new())
		self.fsm:addState2(PlayerJumpRightState:new())
		self.fsm:addState2(PlayerMoveLeftState:new())
		self.fsm:addState2(PlayerMoveRightState:new())
		self.fsm:addState2(PlayerReadyState:new())
		self.fsm:addState2(PlayerIdleState:new())
		self.fsm:addState2(PlayerGrappleTreasureState:new())
		self.fsm:addState2(PlayerClimbLadderState:new())
		self.fsm:setInitialState("ready")
	end

	function player:enable()
		if self.enabled == false then
			self.bodyType = "dynamic"
			self.enabled = true
			gameLoop:addLoop(self.fsm)
			self.fsm:changeState("ready")
			Runtime:addEventListener("onPlayerLadderCollisionBegan", self)
			Runtime:addEventListener("onPlayerLadderCollisionEnded", self)
			--self:addEventListener("postCollision", self)
		end
	end

	function player:disable()
		if self.enabled == true then
			self.enabled = false
			--self:removeEventListener("postCollision", self)
			self.fsm:changeState("idle")
			gameLoop:removeLoop(self.fsm)
			self.bodyType = "static"
			self.x = -999
			self.y = -999
			Runtime:removeEventListener("onPlayerLadderCollisionBegan", self)
			Runtime:removeEventListener("onPlayerLadderCollisionEnded", self)
		end
	end


	function player:showSprite(name)
		local sprite = self.sprite
		sprite:setSequence(name)
		sprite:play()
	end

	function player:setDirection(dir)
		self.direction = dir
		assert(self.direction ~= nil, "You cannot set direction to a nil value.")
		local spriteHolder = player.sprite
		if dir == "right" then
			spriteHolder.xScale = 1
			--spriteHolder.x = 11
		else
			spriteHolder.xScale = -1
			--spriteHolder.x = spriteHolder.width
			--spriteHolder.x = 11

		end
	end

	function player:startMoving()
		if self.moving == false and self.jumping == false then
			self.moving = true
			self.startMoveTime = system.getTimer()
		end
	end
	
	function player:stopMoving()
		self.moving = false
	end

	function player:startClimbing()
		self.climbing = true
		self.bodyType = "kinematic"
	end

	function player:stopClimbing()
		self.climbing = false
		self.bodyType = "dynamic"
	end

	function player:showGrappleProgress(current, total)
		local bar
		if self.grappleProgressBar then
			bar = self.grappleProgressBar
			bar.isVisible = true
		else
			bar = ProgressBar:new(255, 255, 255, 0, 242, 0, 30, 10)
			local theX, theY = mainGroup:localToContent(self.x, self.y)
			bar.x = theX
			bar.y = theY - 20
			self.grappleProgressBar = bar
		end
		bar:setProgress(current, total)
	end

	function player:hideGrappleProgress()
		if self.grappleProgressBar then
			self.grappleProgressBar.isVisible = false
		end
	end
	
	function player:onPlayerLadderCollisionBegan(event)
		self.lastLadder = event.target
	end

	function player:onPlayerLadderCollisionEnded(event)
		if event.target ~= self.lastLadder then
			self.lastLadder = nil
		end
	end

	player:init()

	return player
end

return Player