require "utils.StateMachine"

SongBook = {}

function SongBook:new()

	local book = display.newGroup()
	book.fsm = nil


	function book:init()
		mainGroup:insert(self)

		local page2 = display.newImage("gui/song-book-images/page2.png")
		self:insert(page2)
		page2.x = 480
		page2.y = 320
		self.page2 = page2

		local page1Sheet = graphics.newImageSheet("gui/song-book-images/page1turn-sheet.png", {width=960, height=640, numFrames=6})
		local page1SequenceData = 
		{
			{
				name="open",
				start=1,
				count=6,
				time=1000,
				loopCount=1
			},
			{
				name="close",
				frames={6, 5, 4, 3, 2, 1},
				time=1000,
				loopCount=1
			}
		}

		local page1 = display.newSprite(page1Sheet, page1SequenceData)
		page1:setSequence("open")
		self:insert(page1)
		page1.x = 480
		page1.y = 320
		self.page1Sheet = covpage1SheeterSheet
		self.page1SequenceData = page1SequenceData
		self.page1 = page1

		function page1:sprite(e)
			if e.phase == "ended" then
				if e.target.sequence == "open" then
					page1:toBack()
					book.cover:toBack()
				end
			end
		end
		page1:addEventListener("sprite", page1)

		local coverSheet = graphics.newImageSheet("gui/song-book-images/cover-turn-sheet.png", {width=960, height=640, numFrames=6})
		local coverSequenceData = 
		{
			{
				name="open",
				start=1,
				count=6,
				time=1000,
				loopCount=1
			},
			{
				name="close",
				frames={6, 5, 4, 3, 2, 1},
				time=1000,
				loopCount=1
			}
		}

		local cover = display.newSprite(coverSheet, coverSequenceData)
		cover:setSequence("open")
		self:insert(cover)
		cover.x = 480
		cover.y = 320
		self.coverSheet = coverSheet
		self.coverSequenceData = coverSequenceData
		self.cover = cover

		function cover:sprite(e)
			if e.phase == "ended" and e.target.sequence == "open" then
				cover:toBack()
			end
		end
		cover:addEventListener("sprite", cover)

		local fsm = StateMachine:new(self)
		self.fsm = fsm
		fsm:addState("cover", {from="page1"})
		fsm:addState("page1", {from={"cover", "page2"}})
		fsm:addState("page2", {from="page1"})
		fsm:setInitialState("cover")
		fsm:addEventListener("onStateMachineStateChanged", self)
	end

	function book:onStateMachineStateChanged(event)
		local state = self.fsm.state
		local prev = self.fsm.previousState
		print(state, prev)
		if state == "cover" then
			self.cover:toFront()
			self.cover:setSequence("close")
			self.cover:play()
		elseif state == "page1" then
			if prev == "cover" then
				self.cover:setSequence("open")
				self.cover:play()
			elseif prev == "page2" then
				self.page1:toFront()
				self.page1:setSequence("close")
				self.page1:play()
			end
		elseif state == "page2" then
			self.page1:setSequence("open")
			self.page1:play()
		end
	end

	function book:destroy()
		self.page2:removeSelf()
		self.page2 = nil

		self.page1:removeEventListener("sprite", self.page1)
		self.page1:removeSelf()
		self.page1 = nil

		self.page1Sheet = nil
		self.page1SequenceData = nil

		self.cover:removeEventListener("sprite", self.cover)
		self.cover:removeSelf()
		self.cover = nil

		self.coverSheet = nil
		self.coverSequenceData = nil

		self.fsm:removeEventListener("onStateMachineStateChanged", self)
		self.fsm = nil

		self:removeSelf()
	end

	book:init()

	return book

end

return SongBook