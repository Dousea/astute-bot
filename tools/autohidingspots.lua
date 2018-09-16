local mappath = ...
--------------------------------------------
local getmapdata = require 'mapdata'
local map = getmapdata(mappath .. '.map')
local iswall = {
	[1] = true,
	[3] = true,
	[5] = true
}
-- [1][2][3]
-- [4][ ][5]
-- [6][7][8]
local checkups = {
	{4, 1, 2},
	{2, 3, 5},
	{5, 8, 7},
	{7, 6, 4}
}
local spots = {}

for x = 0, map 'width' do
	for y = 0, map 'height' do
		local tilemode = map('tile_mode', map('tile', x, y, 'index'))
		
		-- Floors only have indices of 10-16 so...
		if math.floor(tilemode / 10) == 1 then
			local neighbor = {}
			
			for nx = -1, 1 do
				for ny = -1, 1 do
					if not (nx == 0 and ny == 0) then
						neighbor[#neighbor + 1] = map('tile_mode', map('tile', x + nx, y + ny, 'index') or 0) or 0
					end
				end
			end
			
			for _, checkup in ipairs(checkups) do
				if iswall[neighbor[checkup[1]]] and iswall[neighbor[checkup[2]]] and iswall[neighbor[checkup[3]]] then
					spots[#spots + 1] = {x, y}
					
					break
				end
			end
		end
	end
end

local file, err = io.open(mappath .. '.spots', 'w+')

if file then
	file:write('return{')
	
	for _, spot in ipairs(spots) do
		file:write(('{%d,%d},'):format(unpack(spot)))
	end
	
	file:write('}')
	file:close()
else
	error(err, 2)
end