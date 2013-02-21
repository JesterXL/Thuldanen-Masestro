require "gui.MoveLeftButton"
require "gui.MoveRightButton"
require "gui.JumpLeftButton"
require "gui.JumpRightButton"
require "gui.EnterExitButton"

OutOfSphereControls = {}

function OutOfSphereControls:new()

	local controls = display.newGroup()

	function controls:init()
		local jumpLeft = JumpLeftButton:new()
		local jumpRight = JumpRightButton:new()
		local moveLeft = MoveLeftButton:new()
		local moveRight = MoveRightButton:new()
		local enterExit = EnterExitButton:new()

		jumpLeft.y = stage.height - jumpLeft.height
		moveLeft.x = jumpLeft.x + jumpLeft.width + 20
		moveLeft.y = jumpLeft.y
		moveRight.y = moveLeft.y
		moveRight.x = moveLeft.x + moveLeft.width + 20
		jumpRight.y = moveRight.y
		jumpRight.x = moveRight.x + moveRight.width + 20
		enterExit.x = jumpRight.x + jumpRight.width + 20
		enterExit.y = jumpRight.y

		controls:insert(jumpLeft)
		controls:insert(jumpRight)
		controls:insert(moveLeft)
		controls:insert(moveRight)
		controls:insert(enterExit)

		self.jumpLeft = jumpLeft
		self.jumpRight = jumpRight
		self.moveLeft = moveLeft
		self.moveRight = moveRight
		self.enterExit = enterExit
	end

	controls:init()

	return controls

end

return OutOfSphereControls