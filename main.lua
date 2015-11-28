-- love entry point file

lovebird = require("libs/lovebird")
gs = require("libs/states")

-- load stuff
function love.load()
   gs.switch("jeu/game")
end

-- update a frame
function love.update(dt)
   lovebird.update()
   gs.update(dt)
end

-- draw a frame
function love.draw()
   -- don't default to black background (at least for debugging)
   love.graphics.setBackgroundColor(76,76,128)
   -- call current state draw function
   gs.draw()
end

function love.mousepressed(x, y, button)
   gs.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
   gs.mousereleased(x, y, button)
end

function love.keypressed(key, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
   if key == "f5" then
      gs.reload()
   end
   gs.keypressed(key, isrepeat)
end

function love.keyreleased(key)
   gs.keyreleased(key)
end

function love.textinput(text)
   gs.textinput(text)
end
