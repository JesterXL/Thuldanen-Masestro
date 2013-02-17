require "utils.BaseState"
NotesIdleState = {}

function NotesIdleState:new()
	local state = BaseState:new("idle")
	
	function state:onEnterState(event)
		print("Notes idle state")
		local notes = self.entity
		notes:addEventListener("onNoteTouched", self)
		notes.playedNotes = {}
	end
	
	function state:onExitState(event)
		local notes = self.entity
		notes:removeEventListener("onNoteTouched", self)
	end

	function state:onNoteTouched(event)
		self.stateMachine:changeStateToAtNextTick("playing")
	end

	return state
end

return NotesIdleState