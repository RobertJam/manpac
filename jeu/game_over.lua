-- Game Over screen
require("jeu.gui.game_lobby")
--local gui = require("jeu/gui/main_menu")
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
   if love.keyboard.isDown(" ") then state.BackToLobby() end
end

function state.BackToLobby()
   gs.switch("jeu/start")
   
   gui.players = {}

   gui.players[1] = {
		name = game.player.name,
		role = "Hunter",
		userid = game.player.network_id,
		controller = "network",
		ready = false,
		ping = 0,
		host = false
	}
   
   if game.player.role == "hunter" then
      gui.players[1].role = "Hunter"
   else
      gui.players[1].role = "Ghost"
   end
   
   if reseau.host then gui.players[1].host = true end
   
   reseau.removeHostListener(systems.network.hostListener)
   reseau.removeClientListener(systems.network.clientListener)

   gui.game_lobby.Load()
   gui.game_lobby.SendData({action = "back_to_lobby", player = gui.players[1]})
end

return state
