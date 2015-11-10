-- splashscreen state

local state = {}


function state.load()
   print("Loading splash..")
end

function state.update(dt)
   if love.keyboard.isDown("backspace") then
      gs.switch("states/test")
   end
end

function state.draw()
   love.graphics.print("On est dans un nouveau state, backspace pour revenir au main",100,100)
end

return state
