-- Updates commonly used settings on bots
function bot_update_settings()
	BOT_SV_FOW = tonumber(game 'sv_fow')
	BOT_SV_GAMEMODE = tonumber(game 'sv_gamemode')
	BOT_BOT_SKILL = tonumber(game 'bot_skill')
	BOT_BOT_WEAPONS = tonumber(game 'bot_weapons')
	BOT_DEBUGAI = tonumber(game 'debugai')
end

-- Returns a random number with a range from @from to @to with bots' current
-- skill to be taken to the account
function bot_random(from, to)
	from, to = from or 1, math.ceil((to or 5) / (BOT_BOT_SKILL + 1))
	return math.random(from, to < from and from + to or to)
end