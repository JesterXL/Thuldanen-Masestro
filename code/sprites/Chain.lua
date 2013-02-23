Chain = {}

function Chain:new(targetA, targetB)
	local chain = {}
	chain.targetA = targetA
	chain.targetB = targetB
	chain.images = {}
	chain.joints = {}
	chain.TIMEOUT = 500
	chain.lastTick = 0

	function chain:init()
		local targetA = self.targetA
		local targetB = self.targetB
		local distance = getDistance(targetA, targetB)
		local LINK_HEIGHT = 15
		local totalLinks = math.round(distance / LINK_HEIGHT)
		totalLinks = math.max(13, totalLinks)
		if isEven(totalLinks) then
			totalLinks = totalLinks + 1
		end
		local i
		local first = true
		local lastLink

		local images = self.images
		local joints = self.joints
		local chainDensity = 0.01
		
		for i=1,totalLinks do
			local chain
			if isEven(i) == true then
				chain = display.newImage("sprites/chain-link-1.png")
				mainGroup:insert(chain)
				physics.addBody(chain, "dynamic", {density=chainDensity, friction=0.0, bounce=0.1, 
												isSensor=true,
												shape={-5,-8, 5,-8, 5,8, -5,8}})
			else
				chain = display.newImage("sprites/chain-link-2.png")
				mainGroup:insert(chain)
				physics.addBody(chain, "dynamic", {density=chainDensity, friction=0.0, bounce=0.1, 
													isSensor=true,
													shape={-3,-8, 3,-8, 3,8, -3,8}})
			end
			table.insert(images, chain)
			local pivot, mappedX, mappedY
			if first == false then
				chain.x = lastLink.x
				chain.y = lastLink.y - lastLink.height + 4
				pivot = physics.newJoint("pivot", chain, lastLink, lastLink.x, lastLink.y - lastLink.height / 2)
				pivot.isLimitEnabled = true
			pivot:setRotationLimits(-60, 60)
			else
				first = false
				chain.x = targetA.x
				chain.y = targetA.y
				pivot = physics.newJoint("pivot", chain, targetA, chain.x, chain.y + chain.height / 2)
			end
			
			table.insert(joints, pivot)
			lastLink = chain
			lastLink.x = lastLink.x - 20

			if i == totalLinks then
				chain.x = targetB.x
				chain.y = targetB.y
				local finalPivot = physics.newJoint("pivot", chain, targetB, targetB.x, targetB.y)
				finalPivot.isLimitEnabled = true
				finalPivot:setRotationLimits(-60, 60)
				table.insert(joints, finalPivot)
			end
		end
	end

	function chain:destroy()
		local joints = self.joints
		local len = table.maxn(joints)
		local i
		for i=1,len do
			local joint = joints[i]
			joint:removeSelf()
		end
		self.joints = {}

		local images = self.images
		len = table.maxn(images)
		for i=1,len do
			local image = images[i]
			image:removeSelf()
		end
		self.images = {}
	end

	chain:init(targetA, targetB)

	return chain
end

return Chain