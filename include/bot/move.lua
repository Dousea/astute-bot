local method = {}

function method:seek(target)
	local position = vector(player(self._id, 'tilex'), player(self._id, 'tiley'))
	
	local desired_velocity = (target - position):normalize()
	local steering = desired_velocity - self._velocity
	
	self._steering = self._steering + steering
end

function method:pathfollowing()
	local nodes = self._path
	local target = nodes[self._curnode]
		
	if self._curnode < #self._path then
		if helper_dist(player(self._id, 'tilex'), player(self._id, 'tiley'), target.x-1, target.y-1) <= 2 then
			self._curnode = self._curnode + 1
		end
	end
	
	if self._curnode < #self._path then
		self:seek(vector(target.x-1, target.y-1))
		return 2
	elseif self._curnode == #self._path then
		return 1
	end
end

function method:collisionavoidance()
	local bot_tilex, bot_tiley = player(self._id, 'tilex'), player(self._id, 'tiley')
	local angle = self._velocity:angleTo()
	local ahead = vector(math.floor(bot_tilex + math.cos(angle) + .5), math.floor(bot_tiley + math.sin(angle) + .5))
	local closest
	
	for x = bot_tilex-1, bot_tilex+1 do
		for y = bot_tiley-1, bot_tiley+1 do
			if not (x == bot_tilex and y == bot_tiley) and
			   not (x == ahead.x and y == ahead.y) and
			   not tile(x, y, 'walkable') then
				local obstacle = vector(x, y)
				
				if not closest or helper_dist(ahead.x, ahead.y, x, y) <
					              helper_dist(ahead.x, ahead.y, closest.x, closest.y) then
					closest = obstacle
				end
			end
		end
	end
	
	local steering
	
	if closest then
		steering = (ahead - closest):normalize()
	end
	
	self._steering = self._steering + (steering or vector.zero)
end

function method:move()
	self._steering = self._steering / 20 -- 20 is mass
	self._velocity = self._velocity + self._steering
	
	local deg = math.deg(self._velocity:angleTo())
	deg = deg + 90 if deg > -180 and deg < 0 then deg = deg + 360 end
	
	ai_move(self._id, deg)
	
	self._steering = self._steering * 0 -- steering is resetted here
end

return method