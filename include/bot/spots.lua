local helper = require(BOT_DIR .. 'helper')
local method = {}

function method:markscannedspots()
	-- FIXME: It feels heavy, right?
	for id in pairs(self._scannedspots) do
		self._scannedspots[id] = self._scannedspots[id]-1
		
		if self._scannedspots[id] < 0 then
			self._scannedspots[id] = nil
		end
	end
end

function method:setclosespots()
	self._closespots = bot_spots_find(player(self._id, 'tilex'), player(self._id, 'tiley'))
end

function method:scanspot()
	if self._scanspot then
		self._scanspot = nil
	end
	
	local bot_x, bot_y = player(self._id, 'x'), player(self._id, 'y')
	local bot_rot = player(self._id, 'rot')
	local bestid, bestangle
	
	for i = 1, #self._closespots do
		local id = self._closespots[i]
		
		if not self._scannedspots[id] then
			local tilex, tiley = bot_spots_get(id)
			local x, y = tilex * 32 + 16, tiley * 32 + 16
			
			if not self:isonsight(x, y) then
				local angle = math.abs(helper_angledelta(bot_rot, helper_angleto(bot_x, bot_y, x, y)))
				
				if not bestid or angle > bestangle then
					bestid = id
					bestangle = angle
				end
			else
				self._scannedspots[id] = 750
			end
		end
	end
	
	if bestid then
		self._scannedspots[bestid] = 750
		self._scanspot = bestid
	end
end

function method:donthide()
	self._hiding = false
	self._camping = false
	self._covering = false
	self._tohidingspot = nil
end

function method:occupyhidingspot()
	local x, y = player(self._id, 'tilex'), player(self._id, 'tiley')
	
	if player(self._id, 'bot') then
		local id = bot_spots_get(x, y)
		
		if id then
			local _, __, occupier = bots_spots_get(id)
			
			if occupier == 0 then
				bot_spots_occupy(id, self._id)
				
				self._hidingspot = id
				self._hiding = true
				
				if self._tocamp then
					self._tocamp = false
					self._camping = true
				end
				
				if self._tocover then
					self._tocover = false
					self._covering = true
				end
			else
				if self._tocamp then self._tocamp = false end
				if self._tocover then self._tocover = false end
			end
		else
			if self._hidingspot then
				bot_spots_occupy(self._hidingspot, 0)
				
				self._hidingspot = nil
				self._hiding = false
				self._covering = false
				self._camping = false
			end
		end
	else
		local id = bot_spots_get(x, y)
		
		if id then
			bot_spots_occupy(id, self._id)
			
			self._hidingspot = id
		else
			if self._hidingspot then
				bot_spots_occupy(self._hidingspot, 0)
				
				self._hidingspot = nil
			end
		end
	end
end

function method:findhidingspot()
	local bot_x, bot_y = player(self._id, 'tilex'), player(self._id, 'tiley')
	local bestid, bestdist
	
	for i = 1, #self._closespots do
		local id = self._closespots[i]
		local x, y, occupier = bot_spots_get(id)
		
		if occupier == 0 then
			local dist = dist(bot_x, bot_y, x, y)
			
			if not bestid or dist < bestdist then
				bestid = id
				bestdist = dist
			end
		end
	end
	
	if bestid then
		self._tohidingspot = bestid
		self._destx, self._desty = bot_spots_get(bestid)
		self._mode = 2 return
	end
end

return method