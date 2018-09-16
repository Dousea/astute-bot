-- just straight use _G table to hook
setmetatable(_G, {__newindex=function(t, k, v)local hook=k:match'bot_hook_(%w+)'if hook then addhook(hook, k)end rawset(t, k, v) end})

function bot_hook_spawn(id)
	if not player(id, 'bot') then
		bot_invoke(id, 'reset')
	end
end

function bot_hook_attack2(id, mode)
	bot_invoke(id, 'onattack2', mode)
end

function bot_hook_attack(id)
	bot_invoke(id, 'onattack')
end

function bot_hook_move(id, x, y, walk)
	bot_invoke(id, 'onmove', x, y, walk)
end

function bot_hook_movetile(id)
	bot_invoke(id, 'onmovetile')
end

setmetatable(_G, nil)