NotesPM = {}

function NotesPM:new(view)
	local model = {}
	model.view = view
	model.stopNotes = {"c"}
	model.moveRightNotes = {"d", "e"}
	model.moveLeftNotes = {"e", "d"}
	model.jumpRightNotes = {"c", "d", "e"}
	model.jumpLeftNotes = {"e", "d", "c"}

	function model:parseNotes(notesArray)
		if self:matchNotesAndLength(self.stopNotes, notesArray) == true then
			print("You played 'stop'.")
			Runtime:dispatchEvent({name="Notes_onStopRoll", target=self})
			return true
		elseif self:matchNotesAndLength(self.moveRightNotes, notesArray) == true then
			print("You played 'move right'.")
			Runtime:dispatchEvent({name="Notes_onMoveRight", target=self})
			return true
		elseif self:matchNotesAndLength(self.moveLeftNotes, notesArray) == true then
			print("You played 'move left'.")
			Runtime:dispatchEvent({name="Notes_onMoveLeft", target=self})
			return true
		elseif self:matchNotesAndLength(self.jumpLeftNotes, notesArray) == true then
			print("You played 'jump left'.")
			Runtime:dispatchEvent({name="Notes_onJumpLeft", target=self})
			return true
		elseif self:matchNotesAndLength(self.jumpRightNotes, notesArray) == true then
			print("You played 'jump right'.")
			Runtime:dispatchEvent({name="Notes_onJumpRight", target=self})
			return true
		end
		print("Unknown song.")
	end

	function model:matchNotesAndLength(songArray, userNotesArray)
		local counter = 0
		local notesMatch = _.all(songArray, function(note)
			counter = counter + 1
			return note == userNotesArray[counter]
		end)

		if notesMatch == true then
			if #songArray == #userNotesArray then
				return true
			else
				return false
			end
		else
			return false
		end
	end

	return model
end

return NotesPM