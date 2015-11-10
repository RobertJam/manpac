-- love entry point file

lovebird = require("libs/lovebird")
gs = require("libs/states")

-- load stuff
function love.load()
   gs.switch("states/test")
end

-- update a frame
function love.update(dt)
   if love.keyboard.isDown("escape") then
      love.event.quit()
   end
   lovebird.update()
   gs.update(dt)
end

-- draw a frame
function love.draw()
   gs.draw()
end

