VerletChain = {}

function VerletChain:new(targetA, targetB)

	local chain = display.newGroup()
	mainGroup:insert(chain)
	chain.targetA = targetA
	chain.targetB = targetB
	chain.linkImages = {}

	function chain:init()

		local lines = chain
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
				self.pointA.x = self.pointA.x - offx
				self.pointA.y = self.pointA.y - offy
				self.pointB.x = self.pointB.x + offx
				self.pointB.y = self.pointB.y + offy
			end

			return stick
		end

		local targetA = self.targetA
		local targetB = self.targetB
		local distance = getDistance(targetA, targetB)
		local LINK_HEIGHT = 15
		local TOTAL = math.round(distance / LINK_HEIGHT)
		TOTAL = math.max(10, TOTAL)
		TOTAL = TOTAL + 1
		
		local points = {}
		local sticks = {}
		local w = TOTAL * 10

		local i = 1
		while i < TOTAL do
			local vpoint = getVPoint(targetA.x, targetA.y)
			table.insert(points, vpoint)
			if i > 1 then
				local stick = getVStick(points[i - 1], points[i])
				table.insert(sticks, stick)
			end
			i = i + 1
		end

		--for i=1,#sticks do
			--local chain
			--if isEven(i) == false then
			--	chain = display.newImage("sprites/chain-link-1.png")
			--else
			--	chain = display.newImage("sprites/chain-link-2.png")
			--end
			--chain:setReferencePoint(display.TopCenterReferencePoint)
			--table.insert(self.linkImages, chain)
			--self:insert(chain)
		--end

		local gravity = 2
		local onFrame = function()
			--local pointAX, pointAY = targetA:contentToLocal(targetA.x, targetA.y)
			--local pointBX, pointBY = targetB:contentToLocal(targetB.x, targetB.y)
			local pointAX = targetA.x
			local pointAY = targetA.y
			local pointBX = targetB.x
			local pointBY = targetB.y
			local t = #points
			local i = 1
			points[1]:setPos(pointBX, pointBY)
			points[#points]:setPos(pointAX, pointAY)
			while points[i] do
				local point = points[i]
				point.y = point.y + gravity
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
			--local links = self.linkImages
			while i < t do
				local stick = sticks[i]
				--local link = links[i]
				--local deltaY = stick.pointB.y - stick.pointA.y
				--local deltaX = stick.pointB.x - stick.pointB.y
				--local angleDegrees = math.deg(math.atan2(deltaY, deltaX)) - 90
				--print(angleDegrees)
				--local line = display.newLine(lines, stick.pointA.x, stick.pointA.y, stick.pointB.x, stick.pointB.y)
				--line.width = 3
				--line:setColor(255, 0, 0)
				link.x = stick.pointA.x
				link.y = stick.pointA.y
				link.rotation = angleDegrees
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

	end

	chain:init()

	return chain

end

return VerletChain