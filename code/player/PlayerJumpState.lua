require "utils.BaseState"

PlayerJumpState = {}

function PlayerJumpState:new(stateName)
	if stateName == nil or stateName == "" then
		stateName = "jump"
	end
	local state = BaseState:new(stateName)
	state.player = nil
	state.hitLedge = nil
	state.ledge = nil
	state.jumpGravity = nil
	state.lastJump = nil
	state.JUMP_INTERVAL = 100
	state.POINT_OF_NO_RETURN = 5 * 1000
	state.xForce = nil
	state.jumpStartY = nil
	
	function state:onEnterState(event)
		self.hitLedge = false
		
		local player = self.entity
		self.jumpGravity = -4
		self.jumpStartY = player.y
		self.lastJump = system.getTimer()
	end
	
	function state:onExitState(event)
		self.ledge = nil
		self.entity:removeEventListener("collision", self)
	end
	
	function state:tick(time)
		local player = self.entity
		if self.hitLedge == false then
			player.y = player.y + self.jumpGravity
			if system.getTimer() - self.lastJump >= self.JUMP_INTERVAL then
				-- [jwarden 1.2.2012] NOTE: this needs to ease based on time
				self.jumpGravity = self.jumpGravity + .1
				if self.jumpStartY - player.y >= 45 then self.jumpGravity = 0 end
				if self.jumpGravity > 9.8 then self.jumpGravity = 9.8 end
				if self.jumpGravity > 0 then
					player:addEventListener("collision", self)
				end

				if system.getTimer() - self.lastJump >= self.POINT_OF_NO_RETURN then
					player:removeEventListener("collision", self)
					self.stateMachine:changeStateToAtNextTick("ready")
				end
			end
		else
			local ledge = self.ledge
			if ledge.exitDirection == "right" then
				player.x = ledge.x + ledge.width
			else
				player.x = ledge.x - player.width
			end
			player.y = self.ledge.y - player.height
			player.angularVelocity = 0
			player:setLinearVelocity(0, 0)
			self.stateMachine:changeStateToAtNextTick("ready")
		end
	end
	
	function state:collision(event)
		local player = self.entity
		if player == nil then return false end
		local classType = event.other.classType
		if classType == "Floor" then
			player:removeEventListener("collision", self)
			self.stateMachine:changeStateToAtNextTick("ready")
			return true
		elseif event.other.name == "Ledge" then
			self.hitLedge = true
			self.ledge = event.other
			player:removeEventListener("collision", self)
			return true
		elseif classType == nil then
			print("event.other.name:", event.other.name)
			player:removeEventListener("collision", self)
			self.stateMachine:changeStateToAtNextTick("ready")
			return true
		end
	end
	
	return state
end

return PlayerJumpState