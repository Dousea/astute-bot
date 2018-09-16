BOT_DIR = 'bots/include/'

BOT_BEHAVIOR = {} do
	local fromwhere = {'bombdefuse'} for _, from in ipairs(fromwhere) do BOT_BEHAVIOR[from] = require(BOT_DIR .. 'bot/behavior/' .. from) end
end

BOT_WEAPON_SLOTS = {
	secondary = {1, 2, 3, 4, 5, 6},
	primary = {
		10, 11,
		20, 21, 22, 23, 24, 25,
		30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
	}
}

BOT_BUY_WEAPON_PRIMARY = {} for team = 1, 2 do
	local primaryweapons = {
		-- The weapons are ordered from the most expensive to the cheapest
		[3] = {{11, 3000}, {10, 1700}},
		[4] = {{22, 2350}, {24, 1700}, {20, 1500}},
		[6] = {{36, 5000}, {35, 4750}, {37, 4200}}, 
		[7] = {{40, 5750}}
	}
	
	if team == 1 then
		primaryweapons[4][#primaryweapons[4] + 1] = {23, 1400}
		primaryweapons[5] = {{31, 3500}, {34, 2750}, {30, 2500}, {38, 2000}}
	else
		primaryweapons[4][#primaryweapons[4] + 1] = {21, 1250} 
		primaryweapons[5] = {{33, 3500}, {32, 3100}, {34, 2750}, {39, 2250}}
	end
	
	BOT_BUY_WEAPON_PRIMARY[team] = primaryweapons
end

BOT_BUY_WEAPON_SECONDARY = {{5, 1000}, {6, 750}, {3, 650}, {4, 600}}

for weapon = 1, 100 do
	local slot = itemtype(weapon, 'slot')
	
	if slot == 1 or slot == 2 then
		local recoil = itemtype(weapon, 'recoil')
		local dmg, dmg_z1, dmg_z2 = itemtype(weapon, 'dmg'), itemtype(weapon, 'dmg_z1'), itemtype(weapon, 'dmg_z2')
		
		local vol_recoil = (recoil / 6) * 1.25
		local vol_dmg = (dmg + dmg_z1 + dmg_z2) / 530
		local vol = vol_recoil + vol_dmg
		
		-- tactical shield, etc. are either in slot 1 or 2,
		-- so we need to check it over again
		if vol > 0 then
			local vol_bonus = 1.5 + (slot == 1 and 1.5 or 0)
			_G['BOT_NOISE_WEAPON_' .. weapon] = vol + vol_bonus
		end
	end
end