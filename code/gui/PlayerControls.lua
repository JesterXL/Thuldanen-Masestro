require "gui.Notes"
require "gui.OutOfSphereControls"
require "utils.StateMachine"
PlayerControls = {}

function PlayerControls:new()

	local controls = display.newGroup()
	controls.outOfSphereControls = nil
	controls.notes = nil
	controls.fsm = nil

	

	function controls:init()
		local notes = Notes:new()
		local outOfSphereControls = OutOfSphereControls:new()
		self:insert(notes)
		self:insert(outOfSphereControls)
		self.notes = notes
		notes.x = 0
		notes.y = stage.height - notes.height
		self.outOfSphereControls = outOfSphereControls
		outOfSphereControls.isVisible = false

		self.fsm = StateMachine:new(self)
		self.fsm:addState("notes", {from="*"})
		self.fsm:addState("out", {from="*"})
		self.fsm:setInitialState("notes")
		self.fsm:addEventListener("onStateMachineStateChanged", self)
	end

	function controls:onStateMachineStateChanged(event)
		if self.fsm.state == "notes" then
			self.notes.isVisible = true
			self.outOfSphereControls.isVisible = false
		elseif self.fsm.state == "out" then
			self.notes.isVisible = false
			self.outOfSphereControls.isVisible = true
		end
	end

	controls:init()

	return controls

end

return PlayerControls