require "utils.StateMachine"
require "player.PlayerJumpLeftState"
require "player.PlayerJumpRightState"
require "player.PlayerMoveLeftState"
require "player.PlayerMoveRightState"
require "player.PlayerIdleState"
require "player.PlayerReadyState"

Player = {}

function Player:new()
	local player = display.newGroup()
	mainGroup:insert(player)
	player.direction = "right"
	
	player.speed = 1
	player.health = 40

	player.moving = false
	player.jumping = false

	player.fsm = nil
	player.enabled = true

	function player:init()
		self.spriteHolder = display.newGroup()
		self:insert(self.spriteHolder)

		local rect = display.newRect(0, 0, 10, 20)
		player:insert(rect)
		player.rect = rect
		rect.x = 0
		rect.y = 0

		physics.addBody(self, "dynamic", {density=0.3, friction=0.8, bounce=0.2})
		self.isFixedRotation = true

		self.fsm = StateMachine:new(self)
		self.fsm:addState2(PlayerJumpLeftState:new())
		self.fsm:addState2(PlayerJumpRightState:new())
		self.fsm:addState2(PlayerMoveLeftState:new())
		self.fsm:addState2(PlayerMoveRightState:new())
		self.fsm:addState2(PlayerReadyState:new())
		self.fsm:addState2(PlayerIdleState:new())
		self.fsm:setInitialState("ready")
	end

	function player:enable()
		if self.enabled == false then
			self.bodyType = "dynamic"
			self.enabled = true
			gameLoop:addLoop(self.fsm)
			self.fsm:changeState("ready")
		end
	end

	function player:disable()
		if self.enabled == true then
			self.enabled = false
			self.fsm:changeState("idle")
			gameLoop:removeLoop(self.fsm)
			self.bodyType = "static"
			self.x = -999
			self.y = -999
		end
	end


	function player:showSprite()
		-- TODO
	end

	function player:setDirection(dir)
		self.direction = dir
		assert(self.direction ~= nil, "You cannot set direction to a nil value.")
		local spriteHolder = player.spriteHolder
		if dir == "right" then
			spriteHolder.xScale = 1
			spriteHolder.x = 0
		else
			spriteHolder.xScale = -1
			spriteHolder.x = spriteHolder.width
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

	function player:jumpRight()
		self:applyLinearImpulse(1, 1, self.x, self.y)
	end

	function player:jumpLeft()
		self:applyLinearImpulse(-1, 1, self.x, self.y)
	end

	player:init()

	return player
end

return Player