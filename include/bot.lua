local bot = {}

-- Every file in 'bots/include/bot/' directory returns a table of functions or
-- methods to use on the bots, so enumerate the files and add the methods on
-- each created bot
do
	local method = {}
	
	for file in io.enumdir(BOT_DIR .. 'bot') do
		local from = file:match '(.+)%.lua'
		
		if from then
			method[#method + 1] = require(BOT_DIR .. 'bot/' .. from)
		end
	end
	
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

-- Invokes a method with name of @index of a bot with id @id, and of course
-- the optional arguments to send on the method
function bot_invoke(id, index, ...)
	-- Methods can be invoked if bot is already initialized or @index is 'reset'
	local self = bot[id] return (index == 'reset' or self._init) and self[index](self, ...) or nil
end