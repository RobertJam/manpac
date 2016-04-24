-- Game Over screen
require("jeu.gui.game_lobby")
--local gui = require("jeu/gui/main_menu")
local state = {}

function state.enter(status)
   state.status = status
end

function state.update(dt)
end

function state.draw()
   if state.status == "victory" then
      love.graphics.print("Victory !!!!",100,100)
   elseif state.status == "defeat" then
      love.graphics.print("Defeat !!!!",100,100)
   elseif state.status == "disconnected" then
      love.graphics.print("Network connecion lost",100,100)
   end
   love.graphics.print("Press space to return to main menu",100,120)
end

function state.keypressed(key, isrepeat)
   if love.keyboard.isDown(" ") then
      if state.status == "disconnected" then
         state.BackToHome()
      else
         state.BackToLobby()
      end
   end
end

function state.BackToHome()
   reseau.removeHostListener(systems.network.hostListener)
   reseau.removeClientListener(systems.network.clientListener)
   reseau.close()
   gs.switch("jeu/start")
   gui.main_menu.Load()
end

function state.BackToLobby()
   gs.switch("jeu/start")
   
   gui.players = {}

   gui.players[1] = {
		name = game.player_cfg.name,
		role = "Hunter",
		userid = game.player_cfg.network_id,
		controller = "network",
		ready = false,
		ping = 0,
		host = false
	}
   
   if game.player_cfg.role == "hunter" then
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
