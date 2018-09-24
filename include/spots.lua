local spots
local mapspots = {}

-- Load the .spots file of the map, returns error if not exists
do
	local file, err = io.open('maps/' .. map 'name' .. '.spots', 'r')
	
	if file then
		spots = loadstring(file:read '*a')()
		
		for i = 1, #spots do
			local spot = spots[i]
			mapspots[spot[1]] = mapspots[spot[1]] or {}
			mapspots[spot[1]][spot[2]] = {i, 0} -- [1]: spot ID, [2]: occupier ID
		end
	else
		error(err, 2)
	end
end

-- This function has two overloads:
-- 1. bot_spots_get(id)
-- 2. bot_spots_get(x, y)
function bot_spots_get(arg1, arg2)
	if arg1 and not arg2 then
		local spot = spots[arg1]
		return spot[1], spot[2], mapspots[spot[1]][spot[2]][2]
	elseif arg1 and arg2 then
		return mapspots[arg1] and (mapspots[arg1][arg2] and mapspots[arg1][arg2][1])
	end
end

function bot_spots_resetoccupier()
	for i = 1, #spots do
		local spot = spots[i]
		mapspots[spot[1]][spot[2]][2] = 0
	end
end

function bot_spots_occupy(id, occupier)
	local spot = spots[id]
	mapspots[spot[1]][spot[2]][2] = occupier
end

-- Get hiding spots around the x, y (within virtual screen, 26x15 tiles)
function bot_spots_find(x, y)
	local xsize, ysize = map 'xsize', map 'ysize'
	local closest = {}
	
	for mapx = x - 13, x + 13 do
		if mapx >= 0 and mapx <= xsize then
			if mapspots[mapx] then
				for mapy = y - 7, y + 7 do
					if mapy >= 0 and mapy <= ysize then
						if mapspots[mapx][mapy] then
							closest[#closest + 1] = mapspots[mapx][mapy][1]
						end
					end
				end
			end
		end
	end
	
	return closest
end