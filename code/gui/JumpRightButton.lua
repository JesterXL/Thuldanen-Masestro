JumpRightButton = {}

function JumpRightButton:new()
	local button = display.newRect(0, 0, 60, 60)
	function button:touch(event)
		local p = event.phase
		if p == "began" then
			Runtime:dispatchEvent({name = "onJumpPlayerRight", target = event.target})
			return true
		end
	end
	button:addEventListener("touch", button)

	return button
end

return JumpRightButton