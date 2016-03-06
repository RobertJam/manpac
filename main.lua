-- love entry point file

lovebird = require("libs/lovebird")
gs = require("libs/states")
reseau = require("libs/reseau")
timer = require("libs/timer")
audio = require("jeu/audio")

-- load stuff
function love.load()
   math.randomseed(os.time())
   audio.load()
   gs.switch("jeu/start")
   gs.current.Main()
end

-- update a frame
function love.update(dt)
   lovebird.update()
   gs.update(dt)
   reseau.update()
   timer.update()
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
   if key == "f6" then
	  gs.switch("jeu/start")
   end
   gs.keypressed(key, isrepeat)
end

function love.keyreleased(key)
   gs.keyreleased(key)
end

function love.textinput(text)
   gs.textinput(text)
end
