local state = {}

function state.enter()
	local gui = require("libs.gui.main_menu")
	gui.main_menu.Load()
end

function state.update(dt)
	loveframes.update(dt)
end

function state.draw()
	loveframes.draw()
end

function state.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function state.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function state.keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end

function state.keyreleased(key)
	loveframes.keyreleased(key)
end

function state.textinput(text)
	loveframes.textinput(text)
end

return state