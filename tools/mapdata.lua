-- Ortimh (#109798)
return function(path)
	local data = {}
	local file, err = io.open(path, 'rb')
	
	local function throwerr(msg)
		if file then
			file:close()
		end
		
		error('map data: ' .. msg, 3)
	end
	
	if not file then
		throwerr(err)
	end
	
	local function read(bytes, signed)
		local value
		
		if bytes == '*l' then
			local string = file:read(bytes)
			value = string and string:sub(1, #string - 1) or string
		else
			local bits = bytes * 8
			local byte = {file:read(bytes):byte(1, bytes)}
			value = 0
			
			for index = 1, #byte do
				value = value + byte[index] * 2 ^ ((index - 1) * 8)
			end
			
			if signed then
				value = value > 2 ^ (bits - 1) - 1 and value - 2 ^ bits or value
			end
		end
		
		return value
	end
	
	local gamename = read '*l' :match 'Unreal Software\'s (.+) Map File %(max%)'
	
	if gamename then
		data['bg_tilelike'] = read(1) == 1
		data['modifiers'] = read(1) == 1
		local save_tile_heights = read(1)
		data['save_tile_heights'] = not (save_tile_heights == 0)
		data['64x64_tiles'] = read(1) == 1
		
		file:read(6) -- 6 unused bytes
		
		data['system_uptime'] = read(4, true)
		data['author_usgn'] = read(4, true) - 51
		data['daylight_time'] = read(4, true) - 1000
		
		file:read(7 * 4) -- 7 unused ints
		
		data['author'] = read '*l'
		data['program_used'] = read '*l'
		
		for _ = 1, 8 do read '*l' end -- 8 unused strings
		
		data['dimensions'], data['tile_count'], data['system_time'] = read '*l' :match '(%d+)x(%d+)$(%d+)%%%d+'
		data['system_time'] = data['system_time']:gsub('(%d%d)(%d%d)(%d%d)', '%1:%2:%3')
		data['tileset_image'] = read '*l'
		data['tiles_required'] = read(1)
		data['width'] = read(4, true)
		data['height'] = read(4, true)
		data['bg_image'] = read '*l'
		data['bg_speed_x'] = read(4, true)
		data['bg_speed_y'] = read(4, true)
		data['bg_color_r'] = read(1)
		data['bg_color_g'] = read(1)
		data['bg_color_b'] = read(1)
		data['tile_mode'] = {}
		
		if read '*l' == 'ed.erawtfoslaernu' then
			for i = 0, data['tile_count'] do
				data['tile_mode'][i + 1] = read(1)
			end
			
			if data['save_tile_heights'] then
				data['tile_heights'] = {}
				
				for i = 0, data['tile_count'] do
					if save_tile_heights == 1 then
						data['tile_heights'][i + 1] = {read(4, true)}
					elseif save_tile_heights == 2 then
						data['tile_heights'][i + 1] = {read(2), read(1)}
					end
				end
			end
			
			-- Thanks to http://lua-users.org/wiki/BitUtils
			local function testflag(set, flag)
				return set % (2*flag) >= flag
			end
			
			data['tile'] = {}
			
			for x = 0, data['width'] do
				data['tile'][x + 1] = {}
				
				for y = 0, data['height'] do
					data['tile'][x + 1][y + 1] = {}
					local tile = data['tile'][x + 1][y + 1]
					tile['index'] = read(1)
					tile['color_r'] = 255
					tile['color_g'] = 255
					tile['color_b'] = 255
					tile['rot'] = 0
					tile['brightness'] = 100
				end
			end
			
			if data['modifiers'] then
				for x = 0, data['width'] do
					for y = 0, data['height'] do
						local modifier = read(1)
						local bit64, bit128 = testflag(modifier, 64), testflag(modifier, 128)
						
						if bit64 or bit128 then
							if bit64 and bit128 then
								read '*l' -- unused
							else
								local tile = data['tile'][x + 1][y + 1]
								
								if not bit64 and bit128 then
									modifier = modifier - 128
									tile['color_r'] = read(1)
									tile['color_g'] = read(1)
									tile['color_b'] = read(1)
									tile['overlay_frame'] = read(1)
								else
									modifier = modifier - 64
									local modframe = read(1)
									tile['blend_name'] = ({"linear-soft", "linear-hard", "grass", "dirt-soft", "dirt-hard"})[math.ceil((modframe + 1) / 8)]
									tile['blend_dir'] = modframe - 8 * math.floor(modframe / 8)
								end
								
								if modifier > 0 then
									for roti = 1, 3 do
										if (modifier - roti) % 4 == 0 then
											modifier = modifier - roti
											tile['rot'] = roti
											
											break
										end
									end
								end
								
								if modifier >= 4 then
									tile['brightness'] = modifier / 4 * 10
								end
							end
						end
					end
				end
			end
			
			data['entity_count'] = read(4, true)
			data['entity'] = {}
			
			for i = 1, data['entity_count'] do
				data['entity'][i] = {}
				local entity = data['entity'][i]
				entity['name'] = read '*l'
				entity['type'] = read(1)
				entity['x'] = read(4, true)
				entity['y'] = read(4, true)
				entity['trigger'] = read '*l'
				entity['setting'] = {}
				
				for i = 1, 10 do
					entity['setting'][i] = {read(4, true), read '*l'}
				end
			end
		else
			throwerr('wrong map file header confirmation')
		end
	else
		throwerr('wrong map file header')
	end
	
	file:close()
	
	return function(index, ...)
		if type(index) ~= 'string' then error('bad argument #1 (string expected, got ' .. type(index) .. ')', 2) end
		local args = {...}
		local datum = data[index]
		
		if index == 'tile_mode'
		or index == 'tile_heights' then
			if type(args[1]) ~= 'number' then error('bad argument #2 (number expected, got ' .. type(args[1]) .. ')', 2) end
			return datum[args[1] + 1]
		elseif index == 'tile' then
			if type(args[1]) ~= 'number' then error('bad argument #2 (number expected, got ' .. type(args[1]) .. ')', 2) end
			if type(args[2]) ~= 'number' then error('bad argument #3 (number expected, got ' .. type(args[2]) .. ')', 2) end
			if type(args[3]) ~= 'string' then error('bad argument #4 (string expected, got ' .. type(args[3]) .. ')', 2) end
			return datum[args[1] + 1] and (datum[args[1] + 1][args[2] + 1] and datum[args[1] + 1][args[2] + 1][args[3]] or nil) or nil
		elseif index == 'entity' then
			if type(args[1]) ~= 'number' then error('bad argument #2 (number expected, got ' .. type(args[1]) .. ')', 2) end
			if type(args[2]) ~= 'string' then error('bad argument #3 (string expected, got ' .. type(args[2]) .. ')', 2) end
			return datum[args[1]] and datum[args[1]][args[2]] or nil
		end
		
		return datum or error('bad argument #1 (invalid \'' .. index .. '\')', 2)
	end
end