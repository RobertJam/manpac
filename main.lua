-- love entry point file

lovebird = require("libs/lovebird")
gs = require("libs/states")
reseau = require("jeu/reseau")

-- load stuff
function love.load()
   math.randomseed(os.time())
   gs.switch("jeu/start")
end

-- update a frame
function love.update(dt)
   lovebird.update()
   gs.update(dt)
   reseau.update()
end

-- draw a frame
function love.draw()
   -- don't default to black background (at least for debugging)
   love.graphics.setBackgroundColor(76,76,128)
   -- call current state draw function
   gs.draw()
end

-- fermeture de la fenetre
function love.quit()
	reseau.close()
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
