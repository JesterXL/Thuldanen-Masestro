JumpLeftButton = {}

function JumpLeftButton:new()
	local button = display.newRect(0, 0, 60, 60)
	function button:touch(event)
		local p = event.phase
		if p == "began" then
			Runtime:dispatchEvent({name = "onJumpPlayerLeft", target = event.target})
			return true
		end
	end
	button:addEventListener("touch", button)

	return button
end

return JumpLeftButton