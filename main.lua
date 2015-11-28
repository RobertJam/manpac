-- love entry point file

lovebird = require("libs/lovebird")
gs = require("libs/states")

-- load stuff
function love.load()
   gs.switch("jeu/start")
end

-- update a frame
function love.update(dt)
   lovebird.update()
   gs.update(dt)
end

-- draw a frame
function love.draw()
   gs.draw()
end

function love.mousepressed(x, y, button)
	gs.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	gs.mousereleased(x, y, button)
end

function love.keypressed(key, isrepeat)
	gs.keypressed(key, isrepeat)
end

function love.keyreleased(key)
	gs.keyreleased(key)
end

function love.textinput(text)
	gs.textinput(text)
end