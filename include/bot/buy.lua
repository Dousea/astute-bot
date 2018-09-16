local function randweaponfromslot(slot, money)
	-- Picking random weapon with algorithm, so if skill == 0 it'd be randomized from all weapons (inside the slot)
	local randweapon = bot_random(1, #slot)
	local weapon = slot[randweapon]
	
	if money >= weapon[2] then
		return weapon[1]
	else
		-- Go for the cheapest if the money is unsufficient for the random weapon
		return slot[#slot][1]
	end
end

local function newweaponfromslot(ownedweapon, slot, skill, money)
	local weapon
	
	if not ownedweapon then
		weapon = randweaponfromslot(slot, money)
	else
		repeat
			if BOT_BOT_SKILL > 2 then
				weapon = ownedweapon
			else
				weapon = randweaponfromslot(slot, money)
			end
		until itemtype(weapon, 'price') >= itemtype(ownedweapon, 'price')
	end
	
	return weapon
end


local method = {}

function method:buy()
	if map 'nobuying' ~= 0 then return
	elseif self._buy_time > 0 then self._buy_time = self._buy_time-1 return end
	
	local id = self._id
	local team = player(id, 'team')
	local money = player(id, 'money')
	local ownedprimary, ownedsecondary
	
	-- STEP 0: Track owned weapons
	if self._buy_sub == 0 then
		self._primarybought = nil
		self._secondarybought = nil
			
	--	if not self._prevlydead then
			local ownedweapons = {}
			
			for _, type in pairs(playerweapons(id)) do
				ownedweapons[type] = true
			end
			
			local retslot = {}
			
			for slot, weapons in pairs(BOT_WEAPON_SLOTS) do
				for i = 1, #weapons do
					if ownedweapons[weapons[i]] then retslot[slot] = weapons[i] break end
				end
			end
			
			ownedprimary, ownedsecondary = retslot.primary, retslot.secondary
	--	end
	-- STEP 1: Equipment
	elseif self._buy_sub == 1 then
		if map 'mission_bombspots' > 0 then
			if team == 2 then
				if money >= 200 then
					money = money - 200
					
					ai_buy(id, 56)
				end
			end
		end
		
		if money >= 1000 then
			ai_buy(id, 58)
		elseif money >= 650 then
			ai_buy(id, 57)
		end
	-- STEP 2: Primary slot
	elseif self._buy_sub == 2 then
		local primaryweapons = BOT_BUY_WEAPON_PRIMARY[team]
		
		if BOT_BOT_WEAPONS == 0 then
			local buyfromslot = 0
			
			-- Check what primary slots that could be bought
			for slot = 7, 3, -1 do
				local weapons = primaryweapons[slot]
				
				-- From the cheapest
				if money >= weapons[#weapons][2] then
					buyfromslot = slot
					
					break
				end
			end
			
			if buyfromslot > 0 then
				local chosenslot = {}
				-- Doing cumulative chosen slots, so if BOT_BOT_SKILL == 0 all primary slots are chosen slots
				if BOT_BOT_SKILL <= 4 then chosenslot[#chosenslot+1] = 5 chosenslot[#chosenslot+1] = 6 end
				if BOT_BOT_SKILL <= 3 then chosenslot[#chosenslot+1] = 3 end
				if BOT_BOT_SKILL <= 2 then chosenslot[#chosenslot+1] = 7 end
				if BOT_BOT_SKILL <= 1 then chosenslot[#chosenslot+1] = 4 end
				
				for index, slot in ipairs(chosenslot) do
					if math.random(1, #chosenslot) == 1 or index == #chosenslot then -- random math to use the slot or not, or already at the last
						if buyfromslot >= slot then
							self._primarybought = newweaponfromslot(ownedprimary, primaryweapons[slot], BOT_BOT_SKILL, money)
							
							if ownedprimary and self._primarybought ~= ownedprimary then
								ai_selectweapon(id, ownedprimary)
								ai_drop(id)
							end
							
							ai_buy(id, self._primarybought)
							
							break
						end
					end
				end
			end
		elseif BOT_BOT_WEAPONS >= 3 then
			if money >= primaryweapons[BOT_BOT_WEAPONS][#primaryweapons[BOT_BOT_WEAPONS]][2] then
				self._primarybought = newweaponfromslot(ownedprimary, primaryweapons[BOT_BOT_WEAPONS], BOT_BOT_SKILL, money)
				
				if ownedprimary and self._primarybought ~= ownedprimary then
					ai_selectweapon(id, ownedprimary)
					ai_drop(id)
				end
				
				ai_buy(id, self._primarybought)
			end
		end
	-- STEP 3: Grenades (HE or flashbang)
	elseif self._buy_sub == 3 then
		if BOT_BOT_WEAPONS == 0 and money >= 200 then
			-- Random number for buying grenades, so if BOT_BOT_SKILL == 4 then they WILL buy grenades
			if bot_random() == 1 then
				if money >= 300 then
					ai_buy(id, 51)
				elseif money >= 200 then
					ai_buy(id, 52)
				end
			end
		end
	-- STEP 4: Secondary slot
	elseif self._buy_sub == 4 then
		-- Random number for buying handgun, so if BOT_BOT_SKILL == 4 then they WON'T buy a handgun
		if bot_random() > 1 then
			if BOT_BOT_WEAPONS == 0 or BOT_BOT_WEAPONS == 2 then
				self._secondarybought = newweaponfromslot(ownedsecondary, BOT_BUY_WEAPON_SECONDARY, BOT_BOT_SKILL, money)
				
				if ownedsecondary and self._secondarybought ~= ownedsecondary then
					ai_drop(id, ownedsecondary)
				end
				
				ai_buy(id, self._secondarybought)
				
				-- Buy Tactical Shield if necessary
				if not self._primarybought and money >= 1000 then
					self._primarybought = 41
					
					ai_buy(id, self._primarybought)
				end
			end
		end
		
		if not self._secondarybought then
			-- Switch to their defaults if no secondary weapon is bought
			self._secondarybought = team == 1 and 2 or 1
		end
	-- STEP 5: Ammos
	elseif self._buy_sub == 5 then
		-- Ammos are full when bought fresh from the store so... no need to buy them if unnecessary
		if ownedprimary == self._primarybought then
			ai_buy(id, 61)
		end
		
		if ownedsecondary == self._secondarybought then
			ai_buy(id, 62)
		end
	-- STEP 6: Switch weapon
	elseif self._buy_sub == 6 then
		if self._primarybought then
			ai_selectweapon(id, self._primarybought)
		elseif self._secondarybought then
			ai_selectweapon(id, self._secondarybought)
		end
	end
	
	if self._buy_sub <= 6 then
		self._buy_sub = self._buy_sub+1
		self._buy_time = bot_random(1, 10)
	else
		self._buy = true
		self._mode = 0 return
	end
end

return method