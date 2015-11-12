-- game state dispatch menu

local state = {}

-- all available game states
-- add your own test here
local gamestates = {a = "states/example",
                    b = "states/test_sti",
					c = "states/loveframes"}

function state.update(dt)
   for key,state_name in pairs(gamestates) do
      if love.keyboard.isDown(key) then
         states.switch(state_name)
      end
   end
end

function state.draw()
   text_y = 100
   love.graphics.print("Select game state:",100,text_y)
   text_y = text_y + 15
   for key,state_name in pairs(gamestates) do
      love.graphics.print(key .. "/ " .. state_name,100,text_y)
      text_y = text_y + 15
   end
end

return state
