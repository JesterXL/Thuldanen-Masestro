require "audio.SoundManager"
Notes = {}

function Notes:new()

	local notes = display.newGroup()

	function notes:init()
		local notesImage = display.newImage("gui/notes-image.png")
		notesImage:setReferencePoint(display.TopLeftReferencePoint)
		notes:insert(notesImage)
		notes.notesImage = notesImage
		notesImage.x = 0
		notesImage.y = 0

		local max = 9
		local i
		local startX = 2
		local notes = {"c", "d", "e", "f", "g", "a", "b", "chigh"}
		for i=1,max do
			local button = self:createButton(notes[i], startX, 46, 117, 60)
			button:addEventListener("onNoteTouched", self)
			startX = startX + button.width
		end
	end

	function notes:createButton(name, x, y, width, height)
		local button = display.newRect(x, y, width, height)
		button.name = name
		self:insert(button)
		button:setFillColor(255, 255, 0, 100)
		--button:setStrokeColor(255, 0, 0)
		--button.strokeWidth =  4
		function button:touch(e)
			if e.phase == "ended" then
				self:dispatchEvent({name="onNoteTouched", target=self, note=name})
				return true
			end
		end
		button:addEventListener("touch", button)
		return button
	end

	function notes:onNoteTouched(event)
		SoundManager.inst:playGravityNote(event.note)
	end

	

	notes:init()

	return notes

end

return Notes