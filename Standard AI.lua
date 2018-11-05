-- It seems that 'require' accepts dots rather than slashes in common libraries
local _require = require

function require(modname)
	return _require(modname:gsub('%.', '/'))
end

vector = require 'bots.include.lib.vector'

dofile 'bots/include/constants.lua'
dofile 'bots/include/general.lua'
dofile 'bots/include/path.lua'
dofile 'bots/include/spots.lua'
dofile 'bots/include/helper.lua'
dofile 'bots/include/bot.lua'
dofile 'bots/include/hook.lua'

function ai_onspawn(id)
	bot_invoke(id, 'reset')
end

function ai_update_living(id)
	bot_update_settings()
	bot_invoke(id, 'update')
end

function ai_update_dead(id)
end

function ai_hear_radio(source,radio)
end

function ai_hear_chat(source, msg, teamonly)
end