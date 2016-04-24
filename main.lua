-- love entry point file

audio = require("jeu/audio")
lovebird = require("libs/lovebird")
gs = require("libs/states")
reseau = require("libs/reseau")
timer = require("libs/timer")

-- Override run for fixed physics
function love.setUpdateTimestep(ts)
  love.updateTimestep = ts
end

function love.run()
  math.randomseed( os.time() )
  math.random() math.random()
  if love.load then love.load(arg) end
  local dt = 0
  local accumulator = 0
  -- Main loop
  while true do
    -- Process events.
    if love.event then
      love.event.pump()
      for e,a,b,c,d in love.event.poll() do
        if e == "quit" then
          if not love.quit or not love.quit() then
            if love.audio then love.audio.stop() end
            return
          end
        end
        love.handlers[e](a,b,c,d)
      end
    end
    -- Update dt for any uses during this timestep of love.timer.getDelta
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end

    local fixedTimestep = love.updateTimestep

    if fixedTimestep then
      -- see http://gafferongames.com/game-physics/fix-your-timestep
      if dt > 0.25 then
        dt = 0.25 -- note: max frame time to avoid spiral of death
      end
      accumulator = accumulator + dt
      --_logger:debug("love.run - acc=%f fts=%f", accumulator, fixedTimestep)

      while accumulator >= fixedTimestep do
        if love.update then love.update(fixedTimestep) end
        accumulator = accumulator - fixedTimestep
      end
    else
      -- no fixed timestep in place, so just update
      -- will pass 0 if love.timer is disabled
      if love.update then love.update(dt) end
    end
    -- draw
    if love.graphics then
      love.graphics.clear()
      if love.draw then love.draw() end
      if love.timer then love.timer.sleep(0.001) end
      love.graphics.present()
    end
  end
end

-- load stuff
function love.load()
   math.randomseed(os.time())
   love.setUpdateTimestep(1 / 60)
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
