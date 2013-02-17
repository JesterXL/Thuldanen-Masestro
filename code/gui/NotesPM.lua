NotesPM = {}

function NotesPM:new(view)
	local model = {}
	model.view = view
	model.stopNotes = {"c"}
	model.moveRightNotes = {"d", "e"}
	model.moveLeftNotes = {"e", "d"}

	function model:parseNotes(notesArray)
		if self:getStopMatch(notesArray) == true then
			print("You played 'stop'.")
			Runtime:dispatchEvent({name="Notes_onStopRoll", target=self})
			return true
		elseif self:getMoveRightMatch(notesArray) == true then
			print("You played 'move right'.")
			Runtime:dispatchEvent({name="Notes_onMoveRight", target=self})
			return true
		elseif self:getMoveLeftMatch(notesArray) == true then
			print("You played 'move left'.")
			Runtime:dispatchEvent({name="Notes_onMoveLeft", target=self})
			return true
		end

		print("Unknown song.")
	end

	function model:getStopMatch(notesArray)
		local counter = 0
		return _.all(self.stopNotes, function(note)
			counter = counter + 1
			return note == notesArray[counter]
		end)
	end

	function model:getMoveRightMatch(notesArray)
		local counter = 0
		return _.all(self.moveRightNotes, function(note)
			counter = counter + 1
			return note == notesArray[counter]
		end)
	end

	function model:getMoveLeftMatch(notesArray)
		local counter = 0
		return _.all(self.moveLeftNotes, function(note)
			counter = counter + 1
			return note == notesArray[counter]
		end)
	end


	return model
end

return NotesPM