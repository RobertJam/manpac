-- test game state

local state = {}

local gamestates = {a = "states/test",
                    b = "states/splash"}

function state.enter()
   print("Entering test state")
end

function state.leave()
   print("Leaving test state")
end

function state.update(dt)
   for key,state_name in pairs(gamestates) do
      if love.keyboard.isDown(key) then
         states.switch(state_name)
      end
   end
end

function state.draw()
   love.graphics.print("Hello les gens... (ESC to quit)",100,100)
   love.graphics.print("Select game state:",100,130)
   text_y = 145
   for key,state_name in pairs(gamestates) do
      love.graphics.print(key .. "/ " .. state_name,100,text_y)
      text_y = text_y + 15
   end
end

return state
