function generate(path)
	local getmapdata = require 'mapdata'
	local map = getmapdata(path .. '.map')
	
	-- Open .neigh file
	local neighs = {}
	
	do
		local file, err = io.open(path .. '.neigh', 'r')
		
		if file then
			local totaltris = tonumber(file:read '*l':match '[%s*]?(%-?%d+)%s*%-?%d+[%s*]?')
			
			for _ = 1, totaltris do
				local index, tri1, tri2, tri3 = file:read '*l':match '[%s*]?(%-?%d+)%s*(%-?%d+)%s*(%-?%d+)%s*(%-?%d+)[%s*]?'
				neighs[tonumber(index)] = {}
				local neigh = neighs[tonumber(index)]
				if tri1 ~= '-1' then neigh[#neigh + 1] = tri1 end
				if tri2 ~= '-1' then neigh[#neigh + 1] = tri2 end
				if tri3 ~= '-1' then neigh[#neigh + 1] = tri3 end
			end
		else
			error(err, 2)
		end
	end
	
	local parents = {}
	local tris = {}
	
	-- Open .ele file
	do
		local file, err = io.open(path .. '.ele', 'r')
		
		if file then
			local totaltris = tonumber(file:read '*l':match '[%s*]?(%-?%d+)%s*%-?%d+%s*%-?%d+[%s*]?')
			
			for _ = 1, totaltris do
				local index, node1, node2, node3 = file:read '*l':match '[%s*]?(%-?%d+)%s*(%-?%d+)%s*(%-?%d+)%s*(%-?%d+)[%s*]?'
				tris[tonumber(index)] = '{' .. node1 .. ',' .. node2 .. ',' .. node3 .. ',neigh={' .. table.concat(neighs[tonumber(index)], ',') .. '}}'
				index, node1, node2, node3 = tonumber(index), tonumber(node1), tonumber(node2), tonumber(node3)
				parents[node1] = parents[node1] or {}
				parents[node1][#parents[node1] + 1] = index
				parents[node2] = parents[node2] or {}
				parents[node2][#parents[node2] + 1] = index
				parents[node3] = parents[node3] or {}
				parents[node3][#parents[node3] + 1] = index
			end
		else
			error(err, 2)
		end
	end
	
	local nodes = {}
	
	-- Open .node file
	do
		local file, err = io.open(path .. '.node', 'r')
		
		if file then
			local totalnodes = tonumber(file:read '*l':match '[%s*]?(%-?%d+)%s*%-?%d+%s*%-?%d+%s*%-?%d+[%s*]?')
			
			for _ = 1, totalnodes do
				local index, x, y = file:read '*l':match '[%s*]?(%-?%d+)%s*(%-?%d+)%s*(%-?%d+).+'
				parents[tonumber(index)] = parents[tonumber(index)] or {}
				nodes[tonumber(index)] = '{' .. x .. ',' .. y .. ',parent={' .. table.concat(parents[tonumber(index)], ',') .. '}}'
			end
		else
			error(err, 2)
		end
	end
	
	-- Generate hiding spots
	local spots = {}
	
	do
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
							spots[#spots + 1] = '{' .. x .. ',' .. y .. '}'
							
							break
						end
					end
				end
			end
		end
	end
	
	local file, err = io.open(path .. '.nav', 'w+')
	
	if file then
		file:write('return {\nnodes={' .. table.concat(nodes, ',') .. '},\ntris={' .. table.concat(tris, ',') .. '},\nspots={' .. table.concat(spots, ',') .. '}\n}')
		file:close()
	else
		error(err, 2)
	end
end

generate(...)