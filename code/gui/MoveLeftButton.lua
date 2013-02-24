MoveLeftButton = {}

function MoveLeftButton:new()
	local button = display.newRect(0, 0, 60, 60)
	function button:touch(event)
		local p = event.phase
		if p == "began" then
			Runtime:dispatchEvent({name = "onMovePlayerLeftStarted", target = event.target})
			return true
		else
			Runtime:dispatchEvent({name = "onMovePlayerLeftEnded", target = event.target})
			return true
		end
	end
	button:addEventListener("touch", button)

	return button
end

return MoveLeftButton