local method = {}

-- is target found?
function method:istargetfound()
	local target = ai_findtarget(self._id)
	
	if target > 0 then
		if player(target, 'exists') and
		   player(target, 'health') > 0 and
		   player(target, 'team') > 0 then
			local target_x, target_y = player(target, 'x'), player(target, 'y')
			
			if self:isinrange(target_x, target_y) and self:isonsight(target_x, target_y) then
				self._target = target
				self._target_lastx, self._target_lasty = target_x, target_y
				
				return true
			end
		end
	end
	
	self._target = 0
	
	return false
end

-- aim target
function method:aimtarget()
	ai_aim(self._id, player(self._target, 'x'), player(self._target, 'y'))
end

-- aim last seen target's position
function method:aimlastseentarget()
	local target_x, target_y =  self._target_lastx, self._target_lasty
	
	if target_x and target_y then
		if self:isinrange(target_x, target_y) and self:isonsight(target_x, target_y) then
			self._target_lastx, self._target_lasty = nil, nil
		else
			ai_aim(self._id, target_x, target_y)
		end
	end
end

-- aim noise
function method:aimnoise()
	local bx, by = player(self._id, 'x'), player(self._id, 'y')
	local x, y = self._noise_x, self._noise_y
	
	ai_aim(self._id, x, y)
	
	if self:isinrange(x, y) and self:isonsight(x, y) then
		self._noise = false
	end
end

-- scan spot
function method:aimspot()
	local spotx, spoty = bot_spots_get(self._scanspot)
	
	ai_aim(self._id, spotx*32 + 16, spoty*32 + 16)
end

-- aim as move
function method:aimasmove()
	local x, y = math.floor(player(self._id, 'x')), math.floor(player(self._id, 'y'))
	local a = math.atan2(x-self._prevx, self._prevy-y)
	
	ai_aim(self._id, x + math.sin(a)*150, y - math.cos(a)*150)
	
	self._prevx, self._prevy = x, y
end

-- aim randomly
function method:aimrandomly()
	if self._randomaimtime > 0 then
		self._randomaimtime = self._randomaimtime - 1
	else
		self._randomaimtime = math.random(100, 200)
		
		ai_rotate(self._id, math.random(-180, 180))
	end
end

function method:look()
	local isabletolook if self._reaimtime > 0 then
		self._reaimtime = self._reaimtime-1
	else
		self._reaimtime = bot_random(15, 25)
		isabletolook = true
	end
	
	if self:istargetfound() and isabletolook then
		self:aimtarget()
	elseif self._hiding then
		self:aimrandomly()
	elseif self._noise then
		self:aimnoise()
	elseif isabletolook then
		if self._scanspot then
			self:aimspot()
		end
		
		self:aimasmove()
	end
end

return method