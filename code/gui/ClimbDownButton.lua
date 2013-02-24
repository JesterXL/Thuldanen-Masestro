ClimbDownButton = {}

function ClimbDownButton:new()
	local button = display.newRect(0, 0, 60, 60)
	button:setFillColor(0, 0, 255)
	function button:touch(event)
		local p = event.phase
		if p == "began" then
			Runtime:dispatchEvent({name = "onPlayerClimbDownStarted", target = event.target})
		else
			Runtime:dispatchEvent({name = "onPlayerClimbDownEnded", target = event.target})
		end
		return true
	end
	button:addEventListener("touch", button)

	return button
end

return ClimbDownButton