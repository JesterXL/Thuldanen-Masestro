require "utils.BaseState"
NotesPlayingState = {}

function NotesPlayingState:new()
	local state = BaseState:new("playing")
	state.IDLE_TIME = 1 * 1000
	state.elapsedTime = nil
	
	function state:onEnterState(event)
		print("Notes playing state")
		local notes = self.entity
		notes:addEventListener("onNoteTouched", self)
		state.elapsedTime = 0
	end
	
	function state:onExitState(event)
		local notes = self.entity
		notes:removeEventListener("onNoteTouched", self)
	end

	function state:onNoteTouched(event)
		self.elapsedTime = 0
	end

	function state:tick(time)
		self.elapsedTime = self.elapsedTime + time
		if self.elapsedTime >= self.IDLE_TIME then
			local notes = self.entity
			notes:onReadyToProcessNotes()
			self.stateMachine:changeStateToAtNextTick("idle")
		end
	end

	return state
end

return NotesPlayingState