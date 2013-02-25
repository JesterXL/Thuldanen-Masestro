Portal = {}

function Portal:new()
	

	local portal = display.newGroup()

	function portal:init()
		mainGroup:insert(portal)

		local portalSheet = graphics.newImageSheet("sprites/portal-sheet.png", {width=214, height=214, numFrames=60})
		local portalSequenceData = 
		{
			{
				name="open",
				start=1,
				count=60,
				time=2000,
			}
		}

		local portalSprite = display.newSprite(portalSheet, portalSequenceData)
		self:insert(portalSprite)
		portalSprite:setSequence("open")
		self.portalSprite = portalSprite
		portalSprite.isVisible = false

		local sparksSheet = graphics.newImageSheet("sprites/portal-sparks-sheet.png", {width=240, height=160, numFrames=24})
		local sparksSequenceData = 
		{
			{
				name="open",
				start=1,
				count=24,
				time=800,
			}
		}

		local sparksSprite = display.newSprite(sparksSheet, sparksSequenceData)
		self:insert(sparksSprite)
		sparksSprite:setSequence("open")
		self.sparksSprite = sparksSprite
		sparksSprite:addEventListener("sprite", self)
		sparksSprite.isVisible = false

		physics.addBody(self, "static", 
				{isSensor=true, radius=68})
	end

	function portal:sprite(event)
		if event.phase == "loop" then
			self.sparksSprite.isVisible = false
			self.sparksSprite:pause()
		end
	end

	function portal:show()
		local sparksSprite = self.sparksSprite
		sparksSprite.isVisible = true
		sparksSprite:setFrame(1)
		sparksSprite:play()

		self.portalSprite.isVisible = true
		self.portalSprite:play()
		self:cancelTween()
		self.portalSprite.alpha = 0
		self.portalSprite.tweenID = transition.to(self.portalSprite, {alpha=1, time=800, delay=500})

		self:addEventListener("collision", self)
	end

	function portal:cancelTween()
		if self.portalSprite.tweenID then
			transition.cancel(self.portalSprite.tweenID)
		end
	end

	function portal:hide()
		self:cancelTween()
		self.sparksSprite:pause()
		self.sparksSprite.isVisible = false
		self.portalSprite:pause()
		self.portalSprite.isVisible = false
		self:removeEventListener("collision", self)
	end

	function portal:destroy()
		self:cancelTween()
		self:removeEventListener("collision", self)
		self.portalSprite:pause()
		self.portalSprite:removeSelf()
	end

	function portal:collision(e)
		if e.phase == "began" and e.other.classType == "Sphere" then
			Runtime:dispatchEvent({name="onSphereTouchedPortal"})
			return true
		end
	end

	portal:init()

	return portal
end

return Portal