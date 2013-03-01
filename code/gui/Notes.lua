require "audio.SoundManager"
require "utils.StateMachine"
require "gui.NotesIdleState"
require "gui.NotesPlayingState"
require "gui.NotesPM"

Notes = {}

function Notes:new()

	local notes = display.newGroup()
	self.notesImage = nil
	self.fms = nil
	self.playedNotes = {}
	self.pm = nil

	function notes:init()
		local notesImage = display.newImage("gui/notes-image.png")
		notesImage:setReferencePoint(display.TopLeftReferencePoint)
		notes:insert(notesImage)
		notes.notesImage = notesImage
		notesImage.x = 0
		notesImage.y = 0

		-- TODO: this should be a total of 9, but 4 for now
		local max = 4
		local i
		local startX = 3
		local notes = {"c", "d", "e", "f", "g", "a", "b", "chigh"}
		for i=1,max do
			local button = self:createButton(notes[i], startX, 46, 119, 60)
			button:addEventListener("onNoteTouched", self)
			startX = startX + button.width
		end

		self.pm = NotesPM:new(self)

		self.fsm = StateMachine:new(self)
		self.fsm:addState2(NotesIdleState:new())
		self.fsm:addState2(NotesPlayingState:new())
		self.fsm:setInitialState("idle")
	end

	function notes:createButton(name, x, y, width, height)
		assert(name ~= nil, "can't pass a nil name")
		local button = display.newRect(x, y, width, height)
		button.name = name
		self["button" .. name] = button
		self:insert(button)
		button:setFillColor(255, 255, 0)
		button.isHitTestable = true
		button.alpha = 0
		--button:setStrokeColor(255, 0, 0)
		button.strokeWidth =  1
		function button:touch(e)
			if e.phase == "ended" then
				self:flash()
				self:dispatchEvent({name="onNoteTouched", target=self, note=name})
				return true
			end
		end

		function button:flash()
			self:setFillColor(255, 255, 0, 255)
			self.alpha = 1
			if self.tween then
				transition.cancel(self.tween)
			end
			self.tween = transition.to(self, {time=1000, alpha=0, onComplete=button})
		end

		function button:onComplete(tween)
			if self.tween then
				transition.cancel(tween)
				self.tween = nil
			end
		end

		button:addEventListener("touch", button)
		return button
	end

	function notes:onNoteTouched(event)
		table.insert(self.playedNotes, event.note)
		SoundManager.inst:playGravityNote(event.note)
		self:dispatchEvent({name="onNoteTouched", target=self, note=event.note})
	end

	function notes:playNote(note)
		self["button" .. note]:flash()
		SoundManager.inst:playGravityNote(note)
	end

	function notes:playC()
		self:playNote("c")
	end

	function notes:playD()
		self:playNote("d")
	end

	function notes:playE()
		self:playNote("e")
	end

	function notes:playF()
		self:playNote("f")
	end

	function notes:playG()
		self:playNote("g")
	end

	function notes:playA()
		self:playNote("a")
	end

	function notes:playB()
		self:playNote("b")
	end

	function notes:playCHIGH()
		self:playNote("chigh")
	end

	function notes:onReadyToProcessNotes()
		print("You played " .. tostring(table.maxn(self.playedNotes)) .. " notes.")
		self.pm:parseNotes(self.playedNotes)
	end

	notes:init()

	return notes

end

return Notes