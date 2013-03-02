require "audio.SoundManager"
LevelCompletePopup = {}

function LevelCompletePopup:new()

	local popup = display.newGroup()

	function popup:init()
		mainGroup:insert(self)

		local background = display.newRect(0, 0, stage.width, stage.height)
		background:setFillColor(0, 0, 0)
		self:insert(background)
		self.background = background
		background.alpha = 0
		background.tweenID = transition.to(background, {time=500, alpha=0.8, ease=easing.inExpo})

		local sheet = graphics.newImageSheet("gui/level-complete-sheet.png", {width=320, height=214, numFrames=41})
		local sequenceData = 
		{
			{
				name="show",
				start=1,
				count=41,
				time=2350,
				loopCount=1
			}
		}

		local sprite = display.newSprite(sheet, sequenceData)
		sprite:setSequence("show")
		sprite:play()
		self:insert(sprite)
		sprite.x = stage.width / 2
		sprite.y = stage.height / 2
		self.sheet = sheet
		self.sequenceData = sequenceData
		self.sprite = sprite
		sprite.alpha = 0
		sprite.tweenID = transition.to(sprite, {time=500, alpha=1})

		function sprite:sprite(event)
			if event.phase == "ended" then
				popup:showButton()
			end
		end
		sprite:addEventListener("sprite", sprite)

		local button = display.newImage("gui/level-complete-button.png")
		self:insert(button)
		button.x = sprite.x
		button.y = sprite.y + 34
		button.isVisible = false
		self.button = button

		function button:touch(event)
			if event.phase == "ended" then
				popup:dispatchEvent({name="onNextLevelButtonTouched"})
				return true
			end
		end
		button:addEventListener("touch", button)

		SoundManager.inst:playLevelEndMusic()
	end

	function popup:showButton()
		local button = self.button
		local gtween = require("utils.gtween")
		local tween
		button.isVisible = true
		local startX = button.x
		local startY = button.y
		button.x = button.x + 20
		if button.tweenID == nil then
			tween = gtween.new(button, 0.5, {x=startX}, 
				{ease=gtween.easing.outBounce})
		else
			tween = button.tween
			tween:toBeginning()
		end
		button.tween = tween
		tween:play()
	end

	function popup:destroy()
		transition.cancel(self.background.tweenID)
		self.background.tweenID = nil
		self.background:removeSelf()

		self.sheet = nil
		self.sequenceData = nil
		
		transition.cancel(self.sprite.tweenID)
		self.sprite.tweenID = nil
		self.sprite:pause()
		self.sprite:removeSelf()
		self.sprite = nil


		self.button.tween = nil
		self.button:removeSelf()
		self.button = nil

		self:removeSelf()
	end

	popup:init()

	return popup

end

return LevelCompletePopup

