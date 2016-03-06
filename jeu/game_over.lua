-- Game Over screen
local gui = require("jeu/gui/main_menu")
local state = {}

function state.enter(has_won)
   state.has_won = has_won
   timer.removeListener(gui.game_lobby.SendPings)
   timer.removeListener(gui.game_lobby.RefreshPings)
   reseau.removeClientListener(gui.game_lobby.clientListener)
   reseau.removeHostListener(gui.game_lobby.hostListener)
   reseau.close()
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
