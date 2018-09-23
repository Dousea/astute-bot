local bot = {}

do
	local fromwhere = {'general', 'buy', 'spots', 'noise', 'look', 'engage', 'hook'}
	local method = {} for _, from in ipairs(fromwhere) do method[#method+1] = require(BOT_DIR .. 'bot/' .. from) end
	
	local function createbot(id)
		local self = {_id = id}
		
		for i = 1, #method do
			for index, value in pairs(method[i]) do
				if self[index] then error 'check if identifier is already used' end self[index] = value
			end
		end
		
		return self
	end

	for id = 1, 32 do
		bot[id] = createbot(id)
	end
end

function bot_invoke(id, index, ...)
	-- Methods can be invoked if bot is already initialized or @index is 'reset'
	local self = bot[id] return (index == 'reset' or self._init) and self[index](self, ...) or nil
end