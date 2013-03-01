SideBar = {}

function SideBar:new()
	local bar = display.newGroup()

	function bar:init()
		local book = display.newImage("gui/side-bar-images/book.png")
		book:setReferencePoint(display.TopLeftReferencePoint)
		self.book = book
		self:insert(book)
		function book:touch(event)
			if event.phase == "ended" then
				Runtime:dispatchEvent({name="onSongBookButtonTouched"})
				return true
			end
		end
		book:addEventListener("touch", book)

		--[[
		local gravityCrystal = display.newImage("gui/side-bar-images/crystal-black.png")
		gravityCrystal:setReferencePoint(display.TopLeftReferencePoint)
		self.gravityCrystal = gravityCrystal
		self:insert(gravityCrystal)

		book.x = stage.width - book.width - 4
		book.y = stage.height - book.height - 4

		gravityCrystal.x = book.x - gravityCrystal.width - 4
		gravityCrystal.y = book.y
		]]--

		book.x = stage.width - book.width - 4
		book.y = stage.height - book.height - 4
	end

	bar:init()

	return bar
end

return SideBar