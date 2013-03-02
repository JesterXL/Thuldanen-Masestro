TreasureObtainedAnimation = {}

function TreasureObtainedAnimation:new()

	local anime = {}

	function anime:init()
		local sheet = graphics.newImageSheet("gui/treasure-obtained-sheet.png", {width=480, height=320, numFrames=20})
		local sequenceData = 
		{
			{
				name="show",
				start=1,
				count=20,
				time=2000,
				loopCount=1
			}
		}

		local sprite = display.newSprite(sheet, sequenceData)
		sprite:setSequence("show")
		sprite:play()
		sprite.x = stage.width / 2
		sprite.y = stage.height / 2
		self.sheet = sheet
		self.sequenceData = sequenceData
		--self.firstPlay = true
		function sprite:sprite(event)
			--if event.phase == "loop" then
			--	self.firstPlay = false
			--end
			if self.frame == 19 then
				anime:fadeOut()
			end
		end
		sprite:addEventListener("sprite", sprite)
		self.sprite = sprite
	end

	function anime:fadeOut()
		self.sprite.tweenID = transition.to(self.sprite, {time=300, alpha=0, onComplete=anime.onComplete})
	end

	function anime:onComplete(tween)
		anime:destroy()
	end

	function anime:destroy()
		transition.cancel(self.sprite.tweenID)
		self.sprite.tweenID = nil
		self.sprite:removeEventListener("sprite", self.sprite)
		self.sprite:removeSelf()
		self.sheet = nil
		self.sequenceData = nil
	end

	anime:init()

	return anime

end

return TreasureObtainedAnimation