local helper = require(BOT_DIR .. 'helper')
local method = {}

function method:signalnoise(x, y, volume, source)
	local dist = helper_dist(player(self._id, 'x'), player(self._id, 'y'), x, y)
	
	if dist < 640 then	
		if not (self:isinrange(x, y) and self:isonsight(x, y)) then
			if source == 0 or player(self._id, 'team') ~= player(source, 'team') then
				volume = (1 - dist/640) * volume
				
				if not self._noise or volume > self._noise_volume then
					self._noise = true
					self._noise_x, self._noise_y = x, y
					self._noise_maxvolume = volume
					self._noise_volume = volume
					
					return self:goto(math.floor(x/32), math.floor(y/32))
				end
			end
		end
	end
end

function method:diminishnoise()
	if self._noise and self._noise_volume > 0 then
		self._noise_volume = self._noise_volume - self._noise_maxvolume/100 -- with this the volume would be 0 in 2 seconds (50 frames * 2)..
	end
end

return method