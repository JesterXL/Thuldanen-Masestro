PistonBox = {}

function PistonBox:new()

	local box = display.newGroup()
	box.rotationSpeed = 2

	function box:init()
		local basePath = "gui/crystalcanistersimages/"
		
		local i
		for i=4,1,-1 do
			print("i:", i)
			local name = "piston" .. i
			local piston = display.newImage(box, basePath .. name .. ".png")
			self:initChild(name, piston)
		end

		local pistonBox = display.newImage(box, basePath .. "piston-box.png")
		self:initChild("pistonBox", pistonBox)

		for i=1,4 do
			local name = "gear" .. i
			local gear = display.newImage(box, basePath .. "gear.png")
			self:initChild(name, gear)
		end

		self.gear1.x = self.gear1.width / 2
		self.gear1.y = -10
		
		self.gear2.x = 80
		self.gear2.y = -10

		self.gear3.y = 74

		self.gear4.x = 80
		self.gear4.y = 74

		self.piston1.x = self.pistonBox.x + self.pistonBox.width / 2 - self.piston1.width / 2 + 8
		self.piston1.y = self.pistonBox.y + self.pistonBox.height / 4 - self.piston1.height / 2

		self.piston2.x = self.piston1.x + self.piston1.width - self.piston2.width
		self.piston2.y = self.piston1.y

		self.piston3.x = self.piston2.x + self.piston2.width - self.piston3.width
		self.piston3.y = self.piston2.y

		self.piston4.x = self.piston3.x + self.piston3.width - self.piston4.width
		self.piston4.y = self.piston3.y
	end

	function box:initChild(name, child)
		assert(name ~= nil, "You cannot pass a nil name.")
		assert(child, "You cannot pass a nil child.")
		self[name] = child
		self:insert(child)
	end

	function box:startSpinningGears()
		self:stopSpinningGears()
		Runtime:addEventListener("enterFrame", self)
	end

	function box:stopSpinningGears()
		Runtime:removeEventListener("enterFrame", self)
	end

	function box:enterFrame()
		self.gear1.rotation = self.gear1.rotation + self.rotationSpeed
		self.gear3.rotation = self.gear3.rotation + self.rotationSpeed

		self.gear2.rotation = self.gear2.rotation - self.rotationSpeed
		self.gear4.rotation = self.gear4.rotation - self.rotationSpeed
	end

	function box:cancelTween(o)
		if o.id ~= nil then
			transition.cancel(o.id)
			o.id = nil
		end
	end

	function box:expandClaw()

	end

	box:init()

	return box

end

return PistonBox