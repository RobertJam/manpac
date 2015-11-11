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
   gs.draw()
end

