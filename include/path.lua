local grid = require 'bots.include.lib.jumper.grid'
local pathfinder = require 'bots.include.lib.jumper.pathfinder'
local map_grid
local map_pathfinder

-- Creating the grid for Jumper
do
	local map_table = {}

	for y = 0, map 'ysize' - 1 do
		map_table[y+1] = {}
		
		for x = 0, map 'xsize' - 1 do
			map_table[y+1][x+1] = tile(x, y, 'walkable') and 0 or 1
		end
	end
	
	map_grid = grid(map_table)
end

-- Using Jump-Point Search as the primary path-finder
map_pathfinder = pathfinder(map_grid, 'JPS', 0) -- 0 is the value for the walkables

map_pathfinder:setHeuristic 'EUCLIDIAN'

-- Gets the path from @x1, @y1 to @x2, @y2
function bot_path_get(x1, y1, x2, y2)
	-- Apparently the positions here is 0-based indices, so plus ones everywhere
	return map_pathfinder:getPath(x1+1, y1+1, x2+1, y2+1)
end