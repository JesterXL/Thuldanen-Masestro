require "physics"

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

local function testSphereRoll()
	--[[
	local leftWall = getWall(30, 500)
	local rightWall = getWall(30, 500)
	rightWall.x = stage.width - 30
	local floor = getWall(500, 30)
	floor.y = stage.height - 30
	--]]

	--local sphere = getMetalSphere(30)
	require "player.Sphere"
	local sphere = Sphere:new()
	sphere.x = 200
	sphere.y = 400

	local scrollScreen = {}
	scrollScreen.lastScrollTime = system.getTimer()
	function scrollScreen:enterFrame()
		local w = mainGroup.width
		local centerX = w / 2
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

local function testFlashGeneratedGemotry()
	local ground1 = getWallCustom({0,5, 95,-6, 344,34, 346,54, 205,15, 173,56, 2,1})
	--local ground2 = getWallCustom({266,422, 264,477, 610,475, 608,455, 469,436, 437,477, 359,41})
	--local ground3 = getWallCustom({771,238, 826,248, 822,476, 770,437, 725,453, 618,475, 614,453, 616,46})

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


setupGlobals()
setupPhysics()

testSphereRoll()
--testGrapplePoints()
--testVerlets()
testLevel1Floors()
testNotes()
--testUnderscoreAll()
