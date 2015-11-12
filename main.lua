-- love entry point file

lovebird = require("libs/lovebird")
gs = require("libs/states")

-- load stuff
function love.load()
   gs.switch("states/state_menu")
end

-- update a frame
function love.update(dt)
   if love.keyboard.isDown("escape") then
      love.event.quit()
   end
   if love.keyboard.isDown("f1") then
      gs.switch("states/state_menu")
   end
   lovebird.update()
   gs.update(dt)
end

-- draw a frame
function love.draw()
   love.graphics.setBackgroundColor(76,76,128)
   love.graphics.print("F1 for state menu",10,10)
   love.graphics.print("ESC to quit",10,25)
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