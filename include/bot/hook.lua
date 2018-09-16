local method = {}

function method:onattack2(mode)
	local weapon = player(self._id, 'weapontype')
	
	if weapon == 1 or weapon == 32 then
		self._silencer = mode
	end
end

function method:onattack()
--	if BOT_SV_FOW == 0 then
		local weapon = player(self._id, 'weapontype')
		
		if weapon ~= 50 then
			local volume = _G['BOT_NOISE_WEAPON_' .. weapon]
			
			if weapon == 21 or ((weapon == 1 or weapon == 32) and self._silencer == 1) then
				volume = .15
			end
			
			for _, oid in ipairs(player(0, 'team' .. (player(self._id, 'team') == 1 and 2 or 1) .. 'living')) do
				if player(oid, 'bot') then
					bot_invoke(oid, 'signalnoise', player(self._id, 'x'), player(self._id, 'y'), volume, self._id)
				end
			end
		end
--	end
end

function method:onmove(x, y, walk)
--	if BOT_SV_FOW == 0 then
		if walk == 0 then
			local prop = tile(math.floor(x/32), math.floor(y/32), 'property')
			
			if math.floor(prop/10) == 1 then -- basically.. floors
				local volume = (prop/16) * 0.6
				
				for _, oid in ipairs(player(0, 'team' .. (player(self._id, 'team') == 1 and 2 or 1) .. 'living')) do
					if player(oid, 'bot') then
						bot_invoke(oid, 'signalnoise', x, y, volume, self._id)
					end
				end
			end
		end
--	end
end

function method:onmovetile()
	self:scanitems()
	
--	if BOT_SV_FOW ~= 0 then
		self:occupyhidingspot()
		self:setclosespots()
		self:scanspot()
--	end
end

return method