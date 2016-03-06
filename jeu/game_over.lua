-- Game Over screen
local state = {}

function state.enter(has_won)
   state.has_won = has_won
end

function state.update(dt)
end

function state.draw()
   if state.has_won then
      love.graphics.print("Victory !!!!",100,100)
   else
      love.graphics.print("Defeat !!!!",100,100)
   end
   love.graphics.print("Press space to return to main menu",100,120)
end

function state.keypressed(key, isrepeat)
   if love.keyboard.isDown(" ") then
      gs.switch("jeu/start")
   end
end

return state
