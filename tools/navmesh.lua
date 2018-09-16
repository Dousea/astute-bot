function generate(mappath)
	local getmapdata = require 'mapdata'
	local map = getmapdata(mappath .. '.map')
	local cases = {}

	do
		local bits = {}
		
		for x = 0, map 'width' * 2 - 1 do
			for y = 0, map 'height' * 2 - 1 do
				local unwalkable = math.floor(map('tile_mode', map('tile', math.floor(x / 2), math.floor(y / 2), 'index')) / 10) ~= 1
				
				if unwalkable then
					bits[x + 1] = bits[x + 1] or {}
					bits[x + 1][y + 1] = true
					bits[x + 1][y + 2] = true
					bits[x + 2] = bits[x + 2] or {}
					bits[x + 2][y + 1] = true
					bits[x + 2][y + 2] = true
				end
			end
		end

		for x = 1, map 'width' * 2 do
			for y = 1, map 'height' * 2 do
				-- [1][2]
				-- [4][3]
				local bit1 = not (bits[x] and bits[x][y])
				local bit2 = not (bits[x + 1] and bits[x + 1][y])
				local bit3 = not (bits[x + 1] and bits[x + 1][y + 1])
				local bit4 = not (bits[x] and bits[x][y + 1])
				local case = 0
				
				if bit1 and bit2 and bit3 and not bit4 then
					case = 1
				elseif bit1 and bit2 and not bit3 and bit4 then
					case = 2
				elseif bit1 and bit2 and not bit3 and not bit4 then
					case = 3
				elseif bit1 and not bit2 and bit3 and bit4 then
					case = 4
				elseif bit1 and not bit2 and bit3 and not bit4 then
					case = 5
				elseif bit1 and not bit2 and not bit3 and bit4 then
					case = 6
				elseif bit1 and not bit2 and not bit3 and not bit4 then
					case = 7
				elseif not bit1 and bit2 and bit3 and bit4 then
					case = 8
				elseif not bit1 and bit2 and bit3 and not bit4 then
					case = 9
				elseif not bit1 and bit2 and not bit3 and bit4 then
					case = 10
				elseif not bit1 and bit2 and not bit3 and not bit4 then
					case = 11
				elseif not bit1 and not bit2 and bit3 and bit4 then
					case = 12
				elseif not bit1 and not bit2 and bit3 and not bit4 then
					case = 13
				elseif not bit1 and not bit2 and not bit3 and bit4 then
					case = 14
				elseif not (bit1 and bit2 and bit3 and bit4) then
					case = 15
				end
				
				cases[x] = cases[x] or {}
				cases[x][y] = case
			end
		end
	end

	do
		local casematch = {
			[1] = {
				{ from = '%d-1,%d', [8] = true, [9] = true, [10] = true, [11] = true },
				{ from = '%d,%d+1', [2] = true, [3] = true, [10] = true, [11] = true }
			},
			[2] = {
				{ from = '%d,%d+1', [1] = true, [3] = true, [5] = true, [7] = true },
				{ from = '%d+1,%d', [4] = true, [5] = true, [6] = true, [7] = true }
			},
			[3] = {
				{ from = '%d-1,%d', [1] = true, [3] = true, [5] = true, [7] = true },
				{ from = '%d+1,%d', [2] = true, [3] = true, [10] = true, [11] = true }
			},
			[4] = {
				{ from = '%d,%d-1', [8] = true, [10] = true, [12] = true, [14] = true },
				{ from = '%d+1,%d', [2] = true, [6] = true, [10] = true, [14] = true }
			},
			[5] = {
				{ from = '%d-1,%d', [8] = true, [9] = true, [10] = true, [11] = true },
				{ from = '%d,%d+1', [2] = true, [3] = true, [10] = true, [11] = true },
				{ from = '%d,%d-1', [8] = true, [10] = true, [12] = true, [14] = true },
				{ from = '%d+1,%d', [2] = true, [6] = true, [10] = true, [14] = true }
			},
			[6] = {
				{ from = '%d,%d-1', [4] = true, [5] = true, [6] = true, [7] = true },
				{ from = '%d,%d+1', [2] = true, [6] = true, [10] = true, [14] = true }
			},
			[7] = {
				{ from = '%d-1,%d', [2] = true, [6] = true, [10] = true, [14] = true },
				{ from = '%d,%d-1', [2] = true, [3] = true, [10] = true, [11] = true }
			},
			[8] = {
				{ from = '%d-1,%d', [1] = true, [5] = true, [9] = true, [13] = true },
				{ from = '%d,%d-1', [4] = true, [5] = true, [12] = true, [13] = true }
			},
			[9] = {
				{ from = '%d,%d-1', [8] = true, [9] = true, [10] = true, [11] = true },
				{ from = '%d,%d+1', [1] = true, [5] = true, [9] = true, [13] = true }
			},
			[10] = {
				{ from = '%d-1,%d', [1] = true, [5] = true, [9] = true, [13] = true },
				{ from = '%d,%d-1', [4] = true, [5] = true, [12] = true, [13] = true },
				{ from = '%d,%d+1', [4] = true, [5] = true, [6] = true, [7] = true },
				{ from = '%d+1,%d', [1] = true, [3] = true, [5] = true, [7] = true }
			},
			[11] = {
				{ from = '%d,%d-1', [1] = true, [3] = true, [5] = true, [7] = true },
				{ from = '%d+1,%d', [1] = true, [5] = true, [9] = true, [13] = true }
			},
			[12] = {
				{ from = '%d-1,%d', [8] = true, [10] = true, [12] = true, [14] = true },
				{ from = '%d+1,%d', [4] = true, [5] = true, [12] = true, [13] = true }
			},
			[13] = {
				{ from = '%d,%d+1', [8] = true, [10] = true, [12] = true, [14] = true },
				{ from = '%d+1,%d', [8] = true, [9] = true, [10] = true, [11] = true }
			},
			[14] = {
				{ from = '%d-1,%d', [4] = true, [5] = true, [6] = true, [7] = true },
				{ from = '%d,%d+1', [4] = true, [5] = true, [12] = true, [13] = true }
			}
		}
		
		function GetFromWhere(x, y)
			local case = cases[x + 1][y + 1]
			
			if case == 0 or case == 15 then error('position must be in an outline', 2) end
			
			local fromx, fromy
			
			for _, n in ipairs({{-1, 0}, {0, -1}, {1, 0}, {0, 1}}) do
				local nx, ny = unpack(n)
				local ncase = cases[x + nx + 1][y + ny + 1]
				
				for i = 1, #casematch[case] do
					local frommatch = casematch[case][i]
					fromx, fromy = loadstring('return ' .. frommatch.from:format(x, y))()
					
					if fromx == nx and fromy == ny then
						local tomatch = casematch[case][math.floor(i / 3) == 0 and (i == 1 and 2 or 1) or (i == 3 and 4 or 3)]
						local tox, toy = loadstring('return ' .. tomatch.from:format(x, y))()
						
						if tox == x and toy == y then
							break
						else
							fromx, fromy = nil
						end
					end
				end
				
				if fromx and fromy then
					break
				end
			end
			
			return fromx, fromy
		end
		
		function MarchingSquares(x, y, x0, y0, ox, oy)
			local case = cases[x + 1][y + 1]
			local outline = {{x, y}}
			
			if x == ox and y == oy then
				return outline
			end
			
			if case == 0 or case == 15 then error('must define from an outline', 2) end
			
			for i = 1, #casematch[case] do
				local frommatch = casematch[case][i]
				local fromx, fromy = loadstring('return ' .. frommatch.from:format(x, y))()
				
				if fromx == x0 and fromy == y0 then
					local tomatch = casematch[case][(i == 1 and 2 or 1) or (i == 3 and 4 or 3)]
					local tox, toy = loadstring('return ' .. tomatch.from:format(x, y))()
					local tocase = cases[tox + 1] and cases[tox + 1][toy + 1]
					
					if tocase and frommatch[tocase] then
						local nextoutline = MarchingSquares(tox, toy, x, y, ox, oy)
						
						for i = 1, #nextoutline do
							outline[#outline + 1] = nextoutline[i]
						end
						
						break
					end
					
					if i == #casematch[case] then
						error('unable to go to next case', 2)
					end
				end
			end
			
			return outline
		end
	end

	do
		local function sqr(x)
			return x * x
		end
		
		local function dist2(v, w)
			return sqr(v[1] - w[1]) + sqr(v[2] - w[2])
		end
		
		local function disttosegmentvertd(p, v, w)
			local l2 = dist2(v, w)
			if (l2 == 0) then return dist2(p, v) end
			local t = ((p[1] - v[1]) * (w[1] - v[1]) + (p[2] - v[2]) * (w[2] - v[2])) / l2
			t = math.max(0, math.min(1, t))
			return dist2(p, {
				v[1] + t * (w[1] - v[1]),
				v[2] + t * (w[2] - v[2])
			})
		end
		
		local function disttosegment(p, v, w)
			return math.sqrt(disttosegmentvertd(p, v, w))
		end
		
		function DouglasPeucker(points, epsilon)
			-- Find the point with the maximum distance
			local dmax = 0
			local index = 0
			local len = #points
			
			for i = 2, (len - 1) do
				d = disttosegment(points[i], points[1], points[len])
				
				if d > dmax then
					index = i
					dmax = d
				end
			end
			
			local result
			
			-- If max distance is greater than epsilon, recursively simplify
			if dmax > epsilon then
				-- Recursive call
				local pointstoindex = {}
				
				for i = 1, index do
					pointstoindex[#pointstoindex + 1] = points[i]
				end
				
				local result1 = DouglasPeucker(pointstoindex, epsilon)
				local pointsfromindex = {}
				
				for i = index, len do
					pointsfromindex[#pointsfromindex + 1] = points[i]
				end
				
				result1[#result1] = nil
				local result2 = DouglasPeucker(pointsfromindex, epsilon)
				
				-- Build the result list
				result = {}
				
				for i = 1, #result1 do
					result[#result + 1] = result1[i]
				end
				
				for i = 1, #result2 do
					result[#result + 1] = result2[i]
				end
			else
				result = {points[1], points[len]}
			end
			
			-- Return the result
			return result
		end
	end

	local areas = {}

	do
		local scannedcases = {}
		
		for x = 0, map 'width' * 2 - 1 do
			for y = 0, map 'height'* 2 - 1 do
				if not (scannedcases[x + 1] and scannedcases[x + 1][y + 1]) then
					local case = cases[x + 1][y + 1]
					
					if case ~= 0 and case ~= 15 then
						local fromx, fromy = GetFromWhere(x, y)
						local outline = MarchingSquares(x, y, fromx, fromy, fromx, fromy)
						outline[#outline + 1] = {x, y}
						
						for _, vert in ipairs(outline) do
							local x, y = unpack(vert)
							scannedcases[x + 1] = scannedcases[x + 1] or {}
							scannedcases[x + 1][y + 1] = true
						end
						
						for i = 1, #outline do
							local vert = outline[i]
							vert[1], vert[2] = vert[1] * 16 + 8, vert[2] * 16 + 8
						end
						
						local hole
						
						if case == 1 or
						   case == 11 then
							hole = {-1, 1}
						elseif case == 2 or
							   case == 7 then
							hole = {1, 1}
						elseif case == 3 then
							hole = {0, 1}
						elseif case == 4 or
							   case == 14 then
							hole = {1, -1}
						elseif case == 6 then
							hole = {1, 0}
						elseif case == 8 or
							   case == 13 then
							hole = {-1, -1}
						elseif case == 9 then
							hole = {-1, 0}
						elseif case == 12 then
							hole = {0, -1}
						end
						
						areas[#areas + 1] = {
							hole = {x * 16 + (hole[1] or 0) * 16 + 8, y * 16 + (hole[2] or 0) * 16 + 8},
							outline = DouglasPeucker(outline, 0)
						}
					end
				end
			end
		end
		
		print('Areas: ' .. #areas)

		for index, area in ipairs(areas) do
			print('Area #' .. index .. ' has ' .. #area.outline .. ' tiles' .. (area.hole and ' with hole on ' .. area.hole[1] .. ', ' .. area.hole[2] or ''))
		end
	end

	do
		local file, err = io.open(mappath .. '.poly', 'w+')
		
		if file then
			local totalverts, curverts = 0
			
			for i = 1, #areas do
				totalverts = totalverts + #areas[i].outline
			end
			
			file:write(('%d %d %d %d\n'):format(totalverts, 2, 0, 0))
			
			curverts = 0
			
			for i = 1, #areas do
				for index, vert in ipairs(areas[i].outline) do
					index = curverts + index
					
					file:write(('%d %f %f\n'):format(index, vert[1], vert[2]))
				end
				
				curverts = curverts + #areas[i].outline
			end
			
			file:write(('%d %d\n'):format(totalverts, 0))
			
			curverts = 0
			
			for i = 1, #areas do
				for index, vert in ipairs(areas[i].outline) do
					index = curverts + index
					
					file:write(('%d %d %d\n'):format(index, index == curverts + 1 and curverts + #areas[i].outline or index - 1, index))
				end
				
				curverts = curverts + #areas[i].outline
			end
			
			local holes = {}
			
			for i = 1, #areas do
				local hole = areas[i].hole
				
				if hole then
					holes[#holes + 1] = hole
				end
			end
			
			file:write(('%d\n'):format(#holes))
			
			for index, hole in ipairs(holes) do
				file:write(('%d %f %f\n'):format(index, hole[1], hole[2]))
			end
			
			file:close()
		else
			error(err, 2)
		end
	end
end

generate(...)