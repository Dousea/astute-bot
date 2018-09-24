-- CONSTANT for the directory
BOT_DIR = 'bots/include/'

-- CONSTANT that contains respective methods for each behaviors
BOT_BEHAVIOR = {} do
	local fromwhere = {'bombdefuse'} for _, from in ipairs(fromwhere) do BOT_BEHAVIOR[from] = require(BOT_DIR .. 'bot/behavior/' .. from) end
end

-- CONSTANT that constains all primary and secondary weapons inside the game
BOT_WEAPON_SLOTS = {
	secondary = {1, 2, 3, 4, 5, 6},
	primary = {
		10, 11,
		20, 21, 22, 23, 24, 25,
		30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
	}
}

do
	-- This only sorts on insertion of the table from highest to lowest
	local function insertweapon(list, value)
		local lastinsertion = true
		
		for i = 1, #list do
			-- The elements here are tables of { 'type id', 'price' } and
			-- we need to compare the 'price' (index #2)
			if value[2] > list[i][2] then
				for j = #list, i, -1 do
					list[j + 1] = list[j]
				end
				
				list[i] = value
				lastinsertion = false
				
				break
			end
		end
		
		if lastinsertion then
			list[#list + 1] = value
		end
	end
	
	-- CONSTANT for primary weapons sorted by their prices (highest->lowest)
	BOT_BUY_WEAPON_PRIMARY = {} for team = 1, 2 do
		local primwpns = {}
		local iterprimwpns = {
			[3] = {10, 11},
			[4] = {20, 22, 24},
			[6] = {35, 36, 37},
			[7] = {40}
		}
		
		if team == 1 then
			iterprimwpns[4][#iterprimwpns[4]+1] = 23
			iterprimwpns[5] = {30, 31, 34, 38}
		else
			iterprimwpns[4][#iterprimwpns[4]+1] = 21 
			iterprimwpns[5] = {32, 33, 34, 39}
		end
		
		for slot, wpns in pairs(iterprimwpns) do
			primwpns[slot] = primwpns[slot] or {}
			
			for _, id in ipairs(wpns) do
				insertweapon(primwpns[slot], {id, itemtype(id, 'price')})
			end
		end
		
		BOT_BUY_WEAPON_PRIMARY[team] = primwpns
	end

	-- CONSTANT for secondary weapons sorted by their prices (highest->lowest)
	BOT_BUY_WEAPON_SECONDARY = {} do
		for _, id in ipairs{3, 4, 5, 6} do
			insertweapon(BOT_BUY_WEAPON_SECONDARY, {id, itemtype(id, 'price')})
		end
	end
end

-- CONSTANTS for weapons' noise
for wpn = 1, 100 do
	local slot = itemtype(wpn, 'slot')
	
	if slot == 1 or slot == 2 then
		local recoil = itemtype(wpn, 'recoil')
		local dmg, dmg_z1, dmg_z2 = itemtype(wpn, 'dmg'), itemtype(wpn, 'dmg_z1'), itemtype(wpn, 'dmg_z2')
		
		local vol_recoil = (recoil / 6) * 1.25
		local vol_dmg = (dmg + dmg_z1 + dmg_z2) / 530
		local vol = vol_recoil + vol_dmg
		
		-- Tactical shield, etc. don't create noises on attack
		-- so we need to check if the volume is over 0
		if vol > 0 then
			local vol_bonus = 1.5 + (slot == 1 and 1.5 or 0)
			_G['BOT_NOISE_WEAPON_' .. wpn] = vol + vol_bonus
		end
	end
end