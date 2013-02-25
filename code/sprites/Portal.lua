Portal = {}

function Portal:new()
	

	local sheet = graphics.newImageSheet("sprites/portal-sheet.png", {width=214, height=214, numFrames=60})
	local sequenceData = 
	{
		{
			name="open",
			start=1,
			count=60,
			time=2000,
		}
	}

	local portal = display.newSprite(sheet, sequenceData)
	mainGroup:insert(portal)
	portal:setSequence("open")
	portal:play()

	function portal:show()
		portal.isVisible = true
		portal:play()
	end

	function portal:hide()
		portal:pause()
		portal.isVisible = false
	end

	function portal:destroy()
		self:pause()
		self:removeSelf()
	end

	return portal
end

return Portal