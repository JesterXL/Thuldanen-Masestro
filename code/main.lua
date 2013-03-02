
require "physics"

--[[

	1 meter = 30 pixels
	1.4 meters = 42
	x meters = 64
	3 meters = 90 pixels
	1 meter = 3.3 feet
	3 meters = 9.8 feet

	sphere 209 pixels = x meters
]]--

display.setStatusBar( display.HiddenStatusBar )

local function setupGlobals()
	require "utils.GameLoop"
	_G.gameLoop = GameLoop:new()
	gameLoop:start()

	_G.mainGroup = display.newGroup()
	mainGroup.classType = "mainGroup"
	_G.stage = display.getCurrentStage()

	_G._ = require "utils.underscore"
end

local function setupPhysics()
	physics.setDrawMode("hybrid")
	--physics.setDrawMode("normal")
	physics.start()
	physics.setGravity(0, 9.8)
	physics.setPositionIterations( 10 )

end

local function drawStageBorders()
	local stage = display.getCurrentStage()
	local theX = stage.x
	local theY = stage.y
	local theW = stage.width
	local theH = stage.height

	local bg = display.newRect(theX, theY, theW, theH)
	bg:setStrokeColor(255, 0, 0, 255)
	bg:setFillColor(0, 0, 0, 0)
	bg.strokeWidth = 8

	local bgC = display.newRect(stage.x, stage.y, stage.contentWidth, stage.contentHeight)
	bgC:setStrokeColor(0, 255, 0, 255)
	bgC:setFillColor(0, 0, 0, 0)
	bgC.strokeWidth = 4
end

--drawStageBorders()

function showProps(o)
	print("-- showProps --")
	print("o: ", o)
	for key,value in pairs(o) do
		print("key: ", key, ", value: ", value);
	end
	print("-- end showProps --")
end

function getWall(w, h)
	local wall = display.newRect(0, 0, w, h)
	mainGroup:insert(wall)
	physics.addBody(wall, "static")
	return wall
end

function getWallCustom(shapeTable)
	local wall = display.newRect(0, 0, 6, 6)
	mainGroup:insert(wall)
	physics.addBody(wall, "static", {shape=shapeTable})
	--wall:setReferencePoint(display.TopLeftReferencePoint)
	return wall
end

function getMetalSphere(r)
	local sphere = display.newCircle(0, 0, r)
	mainGroup:insert(sphere)
	physics.addBody(sphere, "dynamic", {density=3, radius=r, bounce=0.0, friction=0.7})
	return sphere
end

function getGrapplePoint()
	local point = display.newRect(0, 0, 10, 10)
	mainGroup:insert(point)
	physics.addBody(point,"static", {density = 1, friction = .5, bounce = .1})
	return point
end

function getChainLink()
	local link = display.newRect(0, 0, 6, 10)
	mainGroup:insert(link)
	physics.addBody(link,"dynamic", {density = 2, friction = 0.1, bounce = 0.1})
	return link
end

function getGearBox()
	local ball = display.newCircle(0, 0, 5)
	mainGroup:insert(ball)
	physics.addBody(ball, "dynamic", {density = 1.7, friction = 0.1, bounce = 0.1})
	return ball
end

function getRoundBall()
	local ball = display.newCircle(0, 0, 5)
	mainGroup:insert(ball)
	physics.addBody(ball, "dyanmic", {density=0.3, friction=0.3, bounce=0.8})
	return ball
end

function getDistance(objA, objB)
	local deltaX = objB.x - objA.x
	local deltaY = objB.y - objA.y
	local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
	return dist
end

function isEven(num)
	if math.mod(num, 2) == 0 then
	  return true
	else
	  return false
	end
end

local function testSphereRoll()
	--[[
	local leftWall = getWall(30, 500)
	local rightWall = getWall(30, 500)
	rightWall.x = stage.width - 30
	local floor = getWall(500, 30)
	floor.y = stage.height - 30
	--]]

	--local sphere = getMetalSphere(30)
	
	local sphere = Sphere:new()
	sphere.x = 200
	sphere.y = 400

	local scrollScreen = {}
	scrollScreen.lastScrollTime = system.getTimer()
	function scrollScreen:enterFrame()
		local w = mainGroup.width
		local centerX = w / 3
		local centerY = mainGroup.y
		
		local playerX, playerY = sphere:localToContent(0, 0)
		local currentOffsetX = playerX - mainGroup.x
		local currentOffsetY = playerY - mainGroup.y
		local deltaX = playerX - centerX
		--local deltaY = playerY - centerY
		local deltaY = (-sphere.y) - mainGroup.y
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
		local speed = 0.15
		local passed = system.getTimer() - self.lastScrollTime
		self.lastScrollTime = system.getTimer()
		local moveX = speed * (deltaX / dist) * passed
		local moveY = speed * (deltaY / dist) * passed
		
		moveX = math.round(moveX)
		moveY = math.round(moveY)
		
		--print("moveX: ", moveX, ", dist: ", dist)
		--print("player.y: ", player.y, ", lvlChildren.y: ", lvlChildren.y)
	--	if lvlChildren.x + -moveX < 0 then
			--lvlChildren.x = lvlChildren.x + -moveX
	--		lvlChildren.x = lvlChildren.x - deltaX
	--	end
		
		mainGroup.x = mainGroup.x - deltaX
		--mainGroup.y = -(sphere.y - 160)
	end

	Runtime:addEventListener("enterFrame", scrollScreen)
end

local function testGrapplePoints()
	
	local grapplePoint = getGrapplePoint()
	grapplePoint.x = 200
	grapplePoint.y = 100

	local secondPoint = getGrapplePoint()
	secondPoint.x = 100
	secondPoint.y = 200
	
	-- physics.newJoint( "rope", object1, object2, anchorX1, anchorY1, anchorX2, anchorY2 )
	----[[
	local grappleLine
	local attachGrapple = function(sphere, point)
		local mappedX, mappedY = sphere:contentToLocal(sphere.x + 2, sphere.y - sphere.height / 2)
		grappleLineRope = physics.newJoint("rope", sphere, point, mappedX, mappedY)
		--grappleLine = physics.newJoint("distance", sphere, point, sphere.x, sphere.y - sphere.height / 2, point.x, point.y)
		--grappleLine.length = 200
		--grappleLine.frequency = 0.7
		--grappleLine.dampingRatio = 1
		--grappleLineRope.maxLength = grappleLine.length + 20

	end

	attachGrapple(sphere, grapplePoint)

	local secondGrappleLine
	local attach2ndGrapple = function(sphere, point)
		--secondGrappleLine = physics.newJoint("distance",sphere, point, sphere.x, sphere.y + sphere.height / 2, point.x, point.y)
		--secondGrappleLine.length = secondGrappleLine.length - 40
		local mappedX, mappedY = sphere:contentToLocal(sphere.x, sphere.y + sphere.height / 2)
		secondGrappleLineRope = physics.newJoint("rope", sphere, point, mappedX, mappedY)
		--secondGrappleLineRope.maxLength = secondGrappleLine.length + 20
	end

	local t = {}
	t.speed = 5
	function t:timer(e)

		if grappleLine ~= nil then
			grappleLine.length = grappleLine.length - t.speed
			if grappleLine.length < 20 then
				--grappleLineRope.maxLength = grappleLine.length + 20
				--grappleLine:removeSelf()
				--grappleLine = nil
				timer.cancel(t.id)
				--t.speed = -1 * t.speed
				attach2ndGrapple(sphere, secondPoint)
			end
		elseif grappleLineRope ~= nil then
			grappleLineRope.maxLength = grappleLineRope.maxLength - t.speed
			if grappleLineRope.maxLength < 40 then
				timer.cancel(t.id)
				attach2ndGrapple(sphere, secondPoint)
			end
		end
	end
	t.id = timer.performWithDelay(1, t, 0)
	--]]--

	local showIt = function()
		if grappleLineRope ~= nil then
			print(grappleLineRope.limitState)
		end

		if secondGrappleLine ~= nil then
			print(secondGrappleLine.limitState)
		end


	end
	--Runtime:addEventListener("enterFrame", showIt)
	

	--[[
	local linkJoints = {}
	local attachGrapple = function(sphere, point)
		local distance = getDistance(sphere, point)
		local LINK_HEIGHT = 10
		local totalLinks = math.floor(distance / LINK_HEIGHT) - 1
		totalLinks = math.max(4, totalLinks / 2)
		local current = 1
		local isFirst = true
		local lastLink
		local startX = sphere.x
		local startY = sphere.y - sphere.height / 2 - 10
		--local gearBox = getGearBox()
		--gearBox.x = sphere.x
		--gearBox.y = sphere.y - sphere.height / 2 - 2
		--local gearPiston = physics.newJoint("wheel", sphere, gearBox, gearBox.x, gearBox.y, 10, 10)
		while current < totalLinks do
			local link = getChainLink()
			link.x = startX
			link.y = startY

			local linkJoint
			if isFirst == false then
				linkJoint = physics.newJoint("distance",lastLink, link, lastLink.x, lastLink.y - lastLink.height / 2, link.x, link.y + link.height / 2)
			else
				isFirst = false
				linkJoint = physics.newJoint("distance",sphere, link, sphere.x, sphere.y - sphere.height / 2, link.x, link.y + link.height / 2)
			end

			lastLink = link
			table.insert(linkJoints, {joint = linkJoint, link = link})
			current = current + 1
		end

		lastLink.x = point.x
		lastLink.y = point.y + lastLink.height
		local finalJoint = physics.newJoint("distance",lastLink, point, lastLink.x, lastLink.y - lastLink.height / 2, point.x, point.y)
		table.insert(linkJoints, {joint = finalJoint, link = link})
    end
    attachGrapple(sphere, grapplePoint)


    local t = {}
	function t:timer(e)
		if t.current == nil then
			t.current = linkJoints[1]
			if t.current == nil then
				timer.cancel(t.id)
				return true
			end
		end

		if t.current.joint.length >= 2 then
			t.current.joint.length = t.current.joint.length - 1
		end

		if t.current.joint.length <= 2 then
			t.current.joint:removeSelf()
			t.current.link:removeSelf()
			table.remove(linkJoints, 1)
			t.current = nil
			t.current = linkJoints[1]
			if t.current == nil then
				timer.cancel(t.id)
				return true
			end
			t.current.joint:removeSelf()
			local link = t.current.link
			local joint = physics.newJoint("distance", sphere, link, sphere.x, sphere.y - sphere.height / 2, link.x, link.y)
			t.current.joint = joint
			--timer.cancel(t.id)
		end
	end
	--t.id = timer.performWithDelay(1, t, 0)
	]]--
end

local function testVerlets()
	local leftWall = getWall(30, 500)
	local rightWall = getWall(30, 500)
	rightWall.x = stage.width - 30
	local floor = getWall(500, 30)
	floor.y = stage.height - 30

	local grapplePoint = getGrapplePoint()
	grapplePoint.x = 200
	grapplePoint.y = 100

	local secondPoint = getGrapplePoint()
	secondPoint.x = 100
	secondPoint.y = 200

	local lines = display.newGroup()
	local clearLines = function()
		local len = lines.numChildren
		while len > 0 do
			local line = lines[len]
			line:removeSelf()
			len = len - 1
		end
	end

	local getVPoint = function(x, y)
		local point = {}
		point.classType = "VPoint"

		function point:setPos(x, y)
			assert(x == x)
			assert(y == y)
			self.x = x
			self.y = y
			self.oldX = x
			self.oldY = y
			--print("initial:, x:", self.x, ", y:", self.y)
			assert(self.x == self.x)
			assert(self.y == self.y)
			assert(self.oldX == self.oldX)
			assert(self.oldY == self.oldY)
		end

		function point:refresh()
			local tempX = self.x
			local tempY = self.y
			local oldOldX = self.oldX
			local oldOrigX = self.x
			local diffX = self.x - self.oldX
			self.x = self.x + (self.x - self.oldX)
			self.y = self.y + (self.y - self.oldY)
			self.oldX = tempX
			self.oldY = tempY
			assert(self.x == self.x, "Failed, oldOldX: " .. oldOldX .. ", vs oldOrigX: " .. oldOrigX .. ", diffX: " .. diffX)
			assert(self.y == self.y)
			assert(self.oldX == self.oldX)
			assert(self.oldY == self.oldY)
		end

		point:setPos(x, y)

		return point
	end

	local getVStick = function(pointA, pointB)
		local stick = {}
		stick.pointA = pointA
		stick.pointB = pointB
		local dx = pointA.x - pointB.x;
		local dy = pointA.y - pointB.y;
		stick.hyp = math.sqrt(dx * dx + dy * dy);

		function stick:contract()
			local dx = self.pointB.x - self.pointA.x
			local dy = self.pointB.y - self.pointA.y
			local h = math.sqrt(dx * dx + dy * dy)
			local diff = self.hyp - h
			local offx = (diff * dx / h) * .5
			local offy = (diff * dy / h) * .5
			--print("dx:", dx, ", dy:", dy)
			--print("h:", h, ", diff:", diff)
			--print("offx:", offx, ", offy:", offy)
			self.pointA.x = self.pointA.x - offx
			self.pointA.y = self.pointA.y - offy
			self.pointB.x = self.pointB.x + offx
			self.pointB.y = self.pointB.y + offy
			--Runtime:dispatchEvent({name="VPoint_changed", target=self})
		end

		return stick
	end

	
	local TOTAL = 10
	local points = {}
	local sticks = {}
	local w = TOTAL * 10

	local i = 1
	while i < TOTAL do
		local vpoint = getVPoint(grapplePoint.x, grapplePoint.y)
		table.insert(points, vpoint)
		if i > 1 then
			local stick = getVStick(points[i - 1], points[i])
			table.insert(sticks, stick)
		end
		i = i + 1
	end

	local onFrame = function()
		local t = #points
		local i = 1
		points[1]:setPos(secondPoint.x, secondPoint.y)
		points[#points]:setPos(grapplePoint.x, grapplePoint.y)
		while points[i] do
			local point = points[i]
			point.y = point.y + 4
			point:refresh()
			i = i + 1
		end

		t = #sticks
		i = 1
		while sticks[i] do
			local stick = sticks[i]
			stick:contract()
			i = i + 1
		end

		clearLines()
		i = 1
		while i < t do
			local stick = sticks[i]
			local line = display.newLine(lines, stick.pointA.x, stick.pointA.y, stick.pointB.x, stick.pointB.y)
			line.width = 3
			line:setColor(255, 0, 0)

			--print("pos:", stick.pointA.x, stick.pointA.y, stick.pointB.x, stick.pointB.y)
			i = i + 1
		end

		return true
	end

	local safeFrame = {}
	function safeFrame:enterFrame()
		local result, e = pcall(onFrame)
		if result ~= true then
			Runtime:removeEventListener("enterFrame", safeFrame)
			print(e)
		end
	end
	Runtime:addEventListener("enterFrame", safeFrame)
	print("********************")
	print("********************")
	print("********************")
	--onFrame()

	--[[
	local i = 1
	local row = 1
	local col = 1
	for row=1,ROWS do
		for col=1,COLS do
			points[row * COLS + col] = getVPoint(col * 10, row * 10)
			if col > 1 then
				sticks[i] = getVStick(points[row * COLS + col-1], points[row * COLS + col])
				i = i + 1
			end
			if row > 1 then
				sticks[i] = getVStick(points[row * COLS + col], points[(row-1) * COLS + col]);
				i = i + 1
			end
			col = col + 1
		end
		row = row + 1
	end

	w = COLS * 10 + 150

	local onTouch = function(e)
		if e.phase == "began" then
			w = e.x
		end
	end
	Runtime:addEventListener("touch", onTouch)
	local onFrame = function()
		local t = points.length
		local i = COLS
		local firstPoint = points[1]
		print(#points)
		points[1]:setPos(0, 0)
		points[COLS - 1]:setPos(w, 0)
		while i < t do
			points[i].y = points[i].y + .2
			points[i]:refresh()
			i = i + 1
		end

		t = sticks.length
		local stiff = 0
		while stiff < 10 do
			i = 1
			while i < t do
				sticks[i]:contract()
				i = i + 1
			end
		end

		--for (i = 0; i < t; i++) {
		--	graphics.moveTo(sticks[i].pointa.x, sticks[i].pointa.y);
		--	graphics.lineTo(sticks[i].pointb.x, sticks[i].pointb.y);
		--end
	end
	local onSafeFrame = function()
		local result, e = pcall(onFrame)
		if result == false then
			print("error:", result, ", e:", e)
			--os.exit(1)
		end
	end
	onSafeFrame()
	--Runtime:addEventListener("enterFrame", onSafeFrame)
	]]--
end

local function testLevel1Floors()
	local level1PhysicsData = (require "levels.level1").physicsData(1.0)
	local function getFloor(name, x, y)
		if x == nil then x = 0 end
		if y == nil then y = 0 end
		local floor = display.newImage("levels/level1/" .. name .. ".png")
		mainGroup:insert(floor)
		floor:setReferencePoint(display.TopLeftReferencePoint)
		floor.x = x
		floor.y = y
		physics.addBody(floor, "static", level1PhysicsData:get(name) )
		return floor
	end
	local floor1 = getFloor("floor-1", 0, 0)
	local floor2 = getFloor("floor-2")
	local floor3 = getFloor("floor-3")
	floor1.y = stage.height - (floor1.height + 80)
	floor2.x = floor1.x + floor1.width
	floor2.y = floor1.y + floor1.height - floor2.height
	floor3.x = floor2.x + floor2.width
	floor3.y = floor2.y + floor2.height - floor3.height
end

local function testNotes()
	require "gui.Notes"
	local notes = Notes:new()
	notes.x = 0
	notes.y = stage.height - notes.height
end

local function testUnderscoreAll()
	local notes = {"d", "e"}
	local myNotes = {"d", "e"}
	local counter = 0
	local match = _.all(notes, function(songNote) 
		counter = counter + 1
		return songNote == myNotes[counter] 
	end)
	print(match)
end

local function testSphereRollLevel1FloorsAndNotes()
	testSphereRoll()
	testLevel1Floors()
	testNotes()
end

local function testGearJoint()
	-- physics.newJoint( "gear", object1, object2, joint1, joint2 )
	local circle1 = display.newCircle(0, 0, 30)
	local circle2 = display.newCircle(0, 0, 30)
	local rect1 = display.newRect(0, 0, 30, 6)
	local rect2 = display.newRect(0, 0, 30, 6)
	rect1:setFillColor(255, 0, 0)
	rect2:setFillColor(255, 0, 0)
	circle1.x = 100
	circle1.y = 100

	circle2.x = 200
	circle2.y = 100

	rect1.x = circle1.x - circle1.width / 2
	rect1.y = circle1.y

	rect2.x = circle2.x - circle2.width / 2
	rect2.y = circle2.y
	physics.addBody(circle1, "kinematic")
	physics.addBody(circle2, "kinematic")
	physics.addBody(rect1, "dynamic")
	physics.addBody(rect2, "dynamic")

	local joint1 = physics.newJoint("pivot", rect1, circle1, rect1.x + rect1.width, rect1.y)
	local joint2 = physics.newJoint("pivot", rect2, circle2, rect2.x + rect2.width, rect2.y)
	--local joint2 = physics.newJoint( "piston", rect2, circle2, rect2.x, rect2.x + rect2.y, circle2.width)
	local joint = physics.newJoint("gear", joint1, joint2, circle1, circle2)

	joint1.isMotorEnabled = true
	joint1.maxMotorTorque = 100000
	joint1.motorSpeed = 500
end

local function testCrystalCanisters()
	require "gui.CrystalCanisters"
	local group = CrystalCanisters:new()
end

local function test2Pistons()

	local leftWall = getWall(30, stage.height)	
	local rightWall = getWall(30, stage.height)
	rightWall.x = stage.width - 30
	local floor = getWall(stage.width, 30)
	floor.y = stage.height - 30

	local box = display.newRect(100, 100, 10, 10)
	physics.addBody(box, "static")

	local bar = display.newRect(100, 100, 10, 100)
	bar:setFillColor(255, 0, 0)
	physics.addBody(bar)
	local piston = physics.newJoint("piston", box, bar, box.x, box.y, 0, box.y)

	piston.isMotorEnabled = true
	speed = 100
	piston.maxMotorForce = 10
	piston.motorSpeed = speed
	piston.isLimitEnabled = true
	piston:setLimits(20, 100)

	local wedge = display.newRect(100, bar.y + bar.height / 2, 10, 10)
	wedge:setFillColor(255, 255, 0)
	physics.addBody(wedge)
	local wedgeWeld = physics.newJoint("weld", wedge, bar, wedge.x, wedge.y)
	local tiny = display.newRect(100, wedge.y + wedge.height + 30, 10, 50)
	tiny:setFillColor(0, 255, 0)
	physics.addBody(tiny)
	local pistonTiny = physics.newJoint("piston", wedge, tiny, wedge.x, wedge.y + wedge.height / 2, 0, tiny.y)
	pistonTiny.isMotorEnabled = true
	pistonTiny.isFixedRotation = true
	pistonTiny.maxMotorForce = 10
	pistonTiny.motorSpeed = 0
	pistonTiny.isLimitEnabled = true
	pistonTiny:setLimits(0, 100)

	direction = "out"

	function change()
		if direction == "out" then
			direction = "in"
			piston.motorSpeed = -speed
		else
			direction = "out"
			piston.motorSpeed = speed
		end	
	end
	--timer.performWithDelay(1000, change, 0)

	local t = {}
	function change2()
		print(piston.jointTranslation )
		if piston.jointTranslation >= 100 then
			timer.cancel(t.id)
			pistonTiny.motorSpeed = 200
		end
	end
	t.id = timer.performWithDelay(1000, change2, 0)
end

local function testPistonBox()
	require "gui.PistonBox"
	local box = PistonBox:new()
	box.x = 100
	box.y = 100
	box:startSpinningGears()
	box:expandClaw()
end

local function testPlayer()
	--testLevel1Floors()
	require "player.Player"
	local player = Player:new()
	player:translate(100, 400)

	require "gui.MoveLeftButton"
	require "gui.MoveRightButton"
	require "gui.JumpLeftButton"
	require "gui.JumpRightButton"
	local jumpLeft = JumpLeftButton:new()
	local jumpRight = JumpRightButton:new()
	local moveLeft = MoveLeftButton:new()
	local moveRight = MoveRightButton:new()

	jumpLeft.y = stage.height - jumpLeft.height
	moveLeft.x = jumpLeft.x + jumpLeft.width + 20
	moveLeft.y = jumpLeft.y
	moveRight.y = moveLeft.y
	moveRight.x = moveLeft.x + moveLeft.width + 20
	jumpRight.y = moveRight.y
	jumpRight.x = moveRight.x + moveRight.width + 20

	--[[
	local t = {}
	function t:timer()
		player:disable()
	end
	timer.performWithDelay(1000, t)

	local cow = {}
	function cow:timer()
		player.x = 100
		player.y = 400
		player:enable()
	end
	timer.performWithDelay(2000, cow)
	]]--
end

local function testPlayerControls()
	require "gui.PlayerControls"
	local controls = PlayerControls:new()
	controls.fsm:changeState("out")

	local t = {}
	function t:timer()
		controls.fsm:changeState("notes")
	end
	timer.performWithDelay(1000, t)

	local cow = {}
	function cow:timer()
		controls.fsm:changeState("out")
	end
	timer.performWithDelay(2000, cow)
end

local function testLevelView()
	--local bg = display.newRect(0, 0, stage.width, stage.height)
	--bg:setFillColor(200, 200, 200)
	--mainGroup:insert(bg)

	require "gui.LevelView"
	local levelView = LevelView:new()
	--levelView:loadLevel("levels._Level1")
	levelView:loadLevel("levels._Level2")

end

local function testPlayerSheet()
	local bg = display.newRect(0, 0, stage.width, stage.height)
	bg:setFillColor(255, 255, 255)

	local sheet = graphics.newImageSheet("player/Player-sheet.png", {width=64, height=64, numFrames=18})
	local sequenceData = 
	{
		{
			name="stand",
			start=1,
			count=3,
			time=1000,
			loopDirection="bounce"
		},
		{
			name="walk",
			frames={1, 4, 5},
			time=1000,
		},
		{
			name="defend",
			start=7,
			count=1,
			time=5000,
		},
		{
			name="attack",
			frames={8, 9, 10, 11, 12, 13, 14},
			time=500
		}
	}

	local sprite = display.newSprite(sheet, sequenceData)
	sprite.x = 200
	sprite.y = 200
	sprite:setSequence("attack")
	sprite:play()
end

local function testSphereSheet()
	local bg = display.newRect(0, 0, stage.width, stage.height)
	bg:setFillColor(255, 255, 255)

	local sheet = graphics.newImageSheet("player/Sphere-sheet.png", {width=224, height=224, numFrames=4})
	local sequenceData = 
	{
		{
			name="doorOpen",
			start=1,
			count=4,
			time=700,
		},
		{
			name="doorClose",
			frames={4,3,2,1},
			time=700,
		},
	}

	local sprite = display.newSprite(sheet, sequenceData)
	sprite.x = 500
	sprite.y = 300
	sprite:setSequence("doorClose")
	sprite:play()
end

local function testChain()
	local grapplePoint = getGrapplePoint()
	grapplePoint.x = 200
	grapplePoint.y = 100

	local secondPoint = getGrapplePoint()
	secondPoint.x = 100
	secondPoint.y = 200

	local i
	local first = true
	local lastLink
	local isEven = function(num)
		if math.mod(num, 2) == 0 then
		  return true
		else
		  return false
		end
	end

	--physics.setVelocityIterations(6)
	--physics.setDrawMode("hybrid")

	for i=1,21 do

		local chain
		if isEven(i) == true then
			chain = display.newImage("sprites/chain-link-1.png")
			physics.addBody(chain, "dynamic", {density=1.3, friction=0.2, bounce=0.1, 
											shape={-5,-8, 5,-8, 5,8, -5,8}})
		else
			chain = display.newImage("sprites/chain-link-2.png")
			physics.addBody(chain, "dynamic", {density=1.3, friction=0.2, bounce=0.1, 
											shape={-3,-8, 3,-8, 3,8, -3,8}})
		end

		mainGroup:insert(chain)
		
		local pivot
		if first == false then
			chain.x = lastLink.x
			chain.y = lastLink.y + lastLink.height / 2 + 4
			pivot = physics.newJoint("pivot", chain, lastLink, lastLink.x, lastLink.y + lastLink.height / 2)
		else
			first = false
			chain.x = grapplePoint.x
			chain.y = grapplePoint.y + grapplePoint.height / 2 + 20
			pivot = physics.newJoint("pivot", grapplePoint, chain, chain.x, chain.y - chain.height / 2)
		end
		pivot.isLimitEnabled = true
		pivot:setRotationLimits( -60, 60 )

		lastLink = chain
		lastLink.x = lastLink.x + 20
	end
end

local function testChain2()
	local grapplePoint = getGrapplePoint()
	grapplePoint.x = 200
	grapplePoint.y = 100

	local secondPoint = getGrapplePoint()
	secondPoint.x = 100
	secondPoint.y = 200

	require "sprites.Chain"
	local chain = Chain:new(grapplePoint, secondPoint)
end

local function testVerletChain()
	local grapplePoint = getGrapplePoint()
	grapplePoint.x = 200
	grapplePoint.y = 100

	local secondPoint = getGrapplePoint()
	secondPoint.x = 100
	secondPoint.y = 200

	require "sprites.VerletChain"
	local chain = VerletChain:new(grapplePoint, secondPoint)
end

local function testProgressBar()
	backgroundRect = display.newRect(stage.x, stage.y, stage.width, stage.height)
	backgroundRect:setFillColor(255, 255, 255)

	require "gui.ProgressBar"
	local bar = ProgressBar:new(255, 255, 255, 0, 242, 0, 30, 10)
	bar.x = 30
	bar.y = 30
	bar:setProgress(5, 10)
	--bar:showProgressAdjusted(5, 4, 10)
	--bar:showProgressAdjusted(5, 7, 10)

	local t = {}
	function t:timer()
		bar:setProgress(8, 10)
	end
	timer.performWithDelay(1000, t)
end

local function testPortalSheet()
	require "sprites.Portal"
	local portal = Portal:new()
	portal.x = 200
	portal.y = 200
	portal:show()


end

local function testTreasure()

	local leftWall = getWall(30, stage.height)	
	local rightWall = getWall(30, stage.height)
	rightWall.x = stage.width - 30
	local floor = getWall(stage.width, 30)
	floor.y = stage.height - 30


	require "sprites.Treasure"
	local box = Treasure:new()
	box.x = 200
	box.y = 300
	box:activateLevitation()
end

local function testLevelComplete()
	require "gui.LevelCompletePopup"
	local pop = LevelCompletePopup:new()

end

local function testCoverTurn()
	require "gui.SongBook"
	local book = SongBook:new()
	book.fsm:changeState("page1")

	local t = {}
	function t:timer()
		book.fsm:changeState("page2")
	end
	timer.performWithDelay(2000, t)

	local cow = {}
	function cow:timer()
		book.fsm:changeState("page1")
	end
	timer.performWithDelay(4000, cow)

	local norp = {}
	function norp:timer()
		book.fsm:changeState("cover")
	end
	timer.performWithDelay(6000, norp)
end

local function testSideBar()
	require "gui.SideBar"
	local bar = SideBar:new()
end

local function testTreasureObtained()
	require "gui.TreasureObtainedAnimation"
	TreasureObtainedAnimation:new()
end

local function testSideBarCrystalSwitch()
	local bg = display.newImage("gui/side-bar-images/side-bar-background-gravity.png")
	local bgElectric = display.newImage("gui/side-bar-images/side-bar-background-electricity.png")
	bgElectric.isVisible = false
	local sheet = graphics.newImageSheet("gui/side-bar-images/side-bar-sheet.png", {width=480, height=320, numFrames=24})
		local sequenceData = 
		{
			{
				name="show",
				start=1,
				count=24,
				time=2000,
				loopCount=1
			}
		}

		local sprite = display.newSprite(sheet, sequenceData)
		sprite:setReferencePoint(display.TopLeftReferencePoint)
		sprite.xScale = 2
		sprite.yScale = 2
		sprite:setSequence("show")
		
		sprite.x = stage.width - (sprite.width * 2)
		sprite.y = stage.height - (sprite.height * 2)
		sprite.isVisible = false
		function sprite:sprite(e)
			if e.phase == "ended" then
				self.isVisible = false
				bg.isVisible = false
				bgElectric.isVisible = true
			end
		end
		sprite:addEventListener("sprite", sprite)

		local t = {}
		function t:timer()
			sprite:play()
			sprite.isVisible = true
		end
		timer.performWithDelay(2000, t)
end

setupGlobals()
setupPhysics()
--backgroundRect = display.newRect(stage.x, stage.y, stage.width, stage.height)
--backgroundRect:setFillColor(255, 255, 255)

--testSphereRoll()
--testGrapplePoints()
--testVerlets()
--testLevel1Floors()
--testNotes()
--testUnderscoreAll()

--testSphereRollLevel1FloorsAndNotes()
--testPlayer()

--testGearJoint()

--testCrystalCanisters()
--test2Pistons()
--testPistonBox()

--testPlayerControls()
--testPlayerSheet()
--testSphereSheet()
--testChain()
--testChain2()
--testVerletChain()
--testProgressBar()
--testPortalSheet()
--testTreasure()
--testLevelComplete()
--testCoverTurn()
--testSideBar()
--testTreasureObtained()
testSideBarCrystalSwitch()

--testLevelView()
