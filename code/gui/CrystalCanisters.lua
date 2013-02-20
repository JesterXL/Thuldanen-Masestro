CrystalCanisters = {}

function CrystalCanisters:new()

	local canisters = display.newGroup()

	function canisters:init()
		local background = display.newImage("gui/crystalcanisters-background.png")
		background:setReferencePoint(display.TopLeftReferencePoint)
		background.x = 688.2
		background.y = -86.75
		canisters:insert(background)
		canisters.background = background

		local crystalGroup = display.newGroup()
		canisters:insert(crystalGroup)
		canisters.crystalGroup = crystalGroup

		local tubes = display.newImage("gui/crystalcanisters-tubes.png")
		tubes:setReferencePoint(display.TopLeftReferencePoint)
		tubes.x = 677.85
		tubes.y = -41.75
		canisters:insert(tubes)
		canisters.tubes = tubes

		local topChainHolder = display.newRect(631, -25, 10, 10)
		local bottomChainHolder = display.newRect(631, 644, 10, 10)

		local pipe = display.newImage("gui/crystalcanisters-pipe.png")
		pipe:setReferencePoint(display.TopLeftReferencePoint)
		canisters:insert(pipe)
		canisters.pipe = pipe
		pipe.x = 631
		pipe.y = -25

	end

	canisters:init()

	return canisters

end

return CrystalCanisters