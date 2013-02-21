EnterExitButton = {}

function EnterExitButton:new()
	local button = display.newRect(0, 0, 60, 60)
	function button:touch(event)
		if event.phase == "ended" then
			Runtime:dispatchEvent({name="onPlayerEnterExitSphere"})
			return true
		end
	end
	button:addEventListener("touch", button)
	return button
end

return EnterExitButton