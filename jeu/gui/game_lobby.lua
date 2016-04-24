gui.game_lobby = {
   gameplay_cfg = require("game_cfg")
}

function gui.game_lobby.Load()
        loveframes = require("libs.loveframes")

        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()

        local object_spaing = 20

        gui.game_lobby.panel = loveframes.Create("panel")
        gui.game_lobby.panel = gui.game_lobby.panel:SetSize(width, height)
        gui.game_lobby.panel = gui.game_lobby.panel:SetPos(0, 0)

        gui.game_lobby.list = loveframes.Create("columnlist", gui.game_lobby.panel)
        gui.game_lobby.list:SetPos(5, 5)
        gui.game_lobby.list:SetSize(400, 450)
        gui.game_lobby.list:AddColumn("Player")
        gui.game_lobby.list:AddColumn("Role")
        gui.game_lobby.list:AddColumn("Ready")
        gui.game_lobby.list:AddColumn("Ping")

        local text = loveframes.Create("text", gui.game_lobby.panel)
        text:SetText("Name")
        text:SetPos(5, 468)
        text:SetSize(30, 15)

        local textinput = loveframes.Create("textinput", gui.game_lobby.panel)
        textinput:SetPos(50, 460)
        textinput:SetSize(355, 30)
        textinput:SetText(gui.players[1].name)
        textinput.OnEnter = gui.game_lobby.ChangeName
        textinput.OnFocusLost = gui.game_lobby.ChangeName

        text = loveframes.Create("text", gui.game_lobby.panel)
        text:SetText("Role")
        text:SetPos(5, 515)
        text:SetSize(30, 15)

        local multichoice = loveframes.Create("multichoice", gui.game_lobby.panel)
        multichoice:SetPos(50, 505)
        multichoice:SetSize(355, 30)
        multichoice:AddChoice("Ghost")
        multichoice:AddChoice("Hunter")
        multichoice:SetChoice(gui.players[1].role)
        multichoice.OnChoiceSelected = function()
                gui.players[1].role = multichoice:GetChoice()
                gui.game_lobby.RefreshList()
                gui.game_lobby.synchronize()
        end

        gui.game_lobby.map_label = loveframes.Create("text", gui.game_lobby.panel)
        gui.game_lobby.map_label:SetText("Map")
        gui.game_lobby.map_label:SetPos(5, 558)
        
        if gui.players[1].host then
           gui.game_lobby.map_label:SetSize(30, 15)
           
           local multichoice = loveframes.Create("multichoice", gui.game_lobby.panel)
           multichoice:SetPos(50, 550)
           multichoice:SetSize(355, 30)
           multichoice.OnChoiceSelected = function()
               gui.game_lobby.current_map = multichoice:GetChoice()
               gui.game_lobby.SendData({action = "change_map",
                                        map = gui.game_lobby.current_map})
           end

           local files = love.filesystem.getDirectoryItems("assets/maps")
           for k, file in ipairs(files) do
               local the_file = "assets/maps/" .. file
               if love.filesystem.isFile(the_file) then
                  local file_ext = string.sub(file, string.find(file, "[.]")+1)
                  local file_name = string.sub(file, 1, string.find(file, "[.]")-1)
                  if file_ext == "lua" then
                     multichoice:AddChoice(file_name)
                  end
               end
           end
           multichoice:SetChoice("sewers")
           gui.game_lobby.current_map = "sewers"
        else
           gui.game_lobby.map_label:SetSize(200, 15)
        end

        gui.game_lobby.tchat = loveframes.Create("textinput", gui.game_lobby.panel)
        gui.game_lobby.tchat:SetPos(415, 5)
        gui.game_lobby.tchat:SetSize(380, 450)
        gui.game_lobby.tchat:SetMultiline(true)
        gui.game_lobby.tchat:SetEditable(false)
        gui.game_lobby.tchat:ShowLineNumbers(false)
        gui.game_lobby.tchat:SetFont(love.graphics.newFont(12))

        local textinput = loveframes.Create("textinput", gui.game_lobby.panel)
        textinput:SetPos(415, 460)
        textinput:SetSize(380, 30)
        textinput.OnEnter = gui.game_lobby.SendMessage

        gui.game_lobby.ready_button = loveframes.Create("button", gui.game_lobby.panel)
        gui.game_lobby.ready_button:SetSize(150, 30)
        gui.game_lobby.ready_button:SetPos(645, 555)
        gui.game_lobby.ready_button.OnClick = gui.game_lobby.GetReady
        if gui.players[1].host then
                gui.game_lobby.ready_button:SetEnabled(false)
                gui.game_lobby.ready_button:SetText("Launch Game")
        else
                gui.game_lobby.ready_button:SetText("Ready")
        end

        local leave_button = loveframes.Create("button", gui.game_lobby.panel)
        leave_button:SetSize(150, 30)
        leave_button:SetPos(490, 555)
        leave_button:SetText("Leave")
        leave_button.OnClick = gui.game_lobby.LeaveLobby
        
        local param_button = loveframes.Create("button", gui.game_lobby.panel)
        param_button:SetSize(150, 30)
        param_button:SetPos(645, 515)
        param_button:SetText("Game params")
        param_button.OnClick = gui.game_lobby.GameParams

        if gui.players[1].host then
                gui.players[1].ready = true
                reseau.addHostListener(gui.game_lobby.hostListener)
                if not reseau.host then
                  reseau.start_server(manpac.port)
                  gui.game_lobby.AddText("Server started on port 9500")
                else
                  gui.game_lobby.AddText("Welcome back to lobby")
                end
                timer.addListener(gui.game_lobby.SendPings, 2000)
                timer.addListener(gui.game_lobby.RefreshPings, 2000)
                timer.wait(gui.game_lobby.RefreshPings, 1000)
        else
                reseau.addClientListener(gui.game_lobby.clientListener)
                gui.game_lobby.AddText("Connected to " .. reseau.hostname)
        end
        gui.game_lobby.RefreshList()
end

function gui.game_lobby.SendPings()
        gui.game_lobby.pingTime = love.timer.getTime()
        gui.game_lobby.SendData({action = "ping"})
end

function gui.game_lobby.RefreshPings()
        gui.game_lobby.RefreshList()
        gui.game_lobby.synchronize()
end

function gui.game_lobby.getPlayerIndex(peer_index)
        for i,player in ipairs(gui.players) do
                if gui.players[i].userid == peer_index then
                        return i
                end
        end
        return -1
end

function gui.game_lobby.hostListener(event)
        if event.type == "connect" then
                gui.game_lobby.newPlayer(event.peer)
        elseif event.type == "disconnect" then
                gui.game_lobby.disconnectedPlayer(event.peer:index())
        elseif event.type == "receive" then
                if event.dec_data
                     and event.dec_data.action ~= "connect"
                     and event.dec_data.action ~= "synchronize"
                     and event.dec_data.action ~= "pong"
                     and event.dec_data.action ~= "back_to_lobby" then
                        reseau.dispatch(event)
                end
                gui.game_lobby.receiveData(event.dec_data, event.peer)
        end
end

function gui.game_lobby.disconnectedPlayer(peer_index)
   local player_index = gui.game_lobby.getPlayerIndex(peer_index)
   if player_index >= 0 then
      gui.game_lobby.AddText(gui.players[player_index].name .. " has left the lobby")
      reseau.disconnect_peer(peer_index)

      local data_object = {
      action = "disconnect_player",
      player_id = peer_index
      }
      gui.game_lobby.SendData(data_object)
      gui.game_lobby.removePlayer(player_index)
   end
end

function gui.game_lobby.removePlayer(player_index)
        table.remove(gui.players, player_index)
        gui.game_lobby.RefreshList()
        
        if table.getn(gui.players) <= 1 then
                gui.game_lobby.ready_button:SetEnabled(false)
        end
end

function gui.game_lobby.newPlayer(peer)
        gui.game_lobby.AddText("A new player has entered the game")
        local data_object = {
                action = "init_id",
                value = peer:index(),
                map = gui.game_lobby.current_map
        }
        
        reseau.send(peer, data_object)
        
        local new_player = {
                name = "Unknown",
                role = "?",
                userid = peer:index(),
                ready = false,
                ping = 0,
                host = false
        }
        table.insert(gui.players, new_player)
        
        gui.game_lobby.ready_button:SetEnabled(true)
        
        gui.game_lobby.synchronize()
        gui.game_lobby.RefreshList()
end

function gui.game_lobby.synchronize()
        local data_object = {action = "synchronize"}
        if gui.players[1].host then
                data_object.players = gui.players
        else
                data_object.players = gui.players[1]
        end
        gui.game_lobby.SendData(data_object)
end

function gui.game_lobby.clientListener(event)
   if event.type == "receive" then
      gui.game_lobby.receiveData(event.dec_data)
   end
end

function gui.game_lobby.hostBusy()
   local frame = loveframes.Create("frame")
   frame:SetModal(true)
   frame:SetName("Server is in game")
   frame:SetDockable(false)
   frame:SetScreenLocked(true)
   frame:ShowCloseButton(false)
   frame:SetWidth(200)
   frame:SetHeight(80)
   frame:Center()

   local button = loveframes.Create("button", frame)
   button:SetText("OK")
   button:SetWidth(100)
   button:Center()
   button.OnClick = function()
      gui.game_lobby.LeaveLobby()
      button:GetParent():Remove()
   end
end

function gui.game_lobby.receiveData(data_object, peer)
   if data_object.action then
      if data_object.action == "message" then
         gui.game_lobby.AddText(data_object.name .. ": " .. data_object.text)
      elseif data_object.action == "rename" then
         gui.game_lobby.AddText(data_object.oldname .. " has changed name to " .. data_object.newname)
      elseif data_object.action == "server_in_game" then
         gui.game_lobby.hostBusy()
      elseif data_object.action == "init_id" then
         gui.players[1].userid = data_object.value
         gui.game_lobby.current_map = data_object.map
         gui.game_lobby.map_label:SetText("Map : " .. data_object.map)
         gui.game_lobby.synchronize()
      elseif data_object.action == "disconnect_player" then
         local player_index = gui.game_lobby.getPlayerIndex(data_object.player_id)
         gui.game_lobby.AddText(gui.players[player_index].name .. " has left the lobby")
         gui.game_lobby.removePlayer(player_index)
      elseif data_object.action == "connect" then
         gui.game_lobby.newPlayer(peer)
      elseif data_object.action == "change_map" then
         gui.game_lobby.map_label:SetText("Map : " .. data_object.map)
         gui.game_lobby.current_map = data_object.map
      elseif data_object.action == "back_to_lobby" then
         if gui.players[1].host then
            table.insert(gui.players, data_object.player)
            gui.game_lobby.ready_button:SetEnabled(true)
            gui.game_lobby.synchronize()
         else
            if(gui.players[1].userid == 0) then
               gui.game_lobby.SendData({action = "connect"})
            else
               gui.game_lobby.SendData({action = "back_to_lobby", player = gui.players[1]})
               gui.game_lobby.synchronize()
            end
         end
      elseif data_object.action == "synchronize" then
         if gui.players[1].host then
            for i,player in ipairs(gui.players) do
               if data_object.players.userid == gui.players[i].userid then
                  gui.players[i] = data_object.players
               end
            end
            gui.game_lobby.synchronize()
         else
            while table.getn(gui.players) > 1 do
               table.remove(gui.players)
            end
            for i,player in ipairs(data_object.players) do
               if data_object.players[i].userid ~= gui.players[1].userid then
                  table.insert(gui.players, data_object.players[i])
               else
                  gui.players[1].ping = data_object.players[i].ping
               end
            end
         end
         gui.game_lobby.RefreshList()
      elseif data_object.action == "ping" then
         local data_object = {action = "pong", player_id = gui.players[1].userid}
         gui.game_lobby.SendData(data_object)
      elseif data_object.action == "pong" then
         local player_index = gui.game_lobby.getPlayerIndex(data_object.player_id)
         gui.players[player_index].ping = math.floor((love.timer.getTime() - gui.game_lobby.pingTime) * 1000)
      elseif data_object.action == "launch" then
         gui.game_lobby.Launch(data_object)
      elseif data_object.action == "get_ready" then
         if not gui.players[1].ready then
            gui.game_lobby.AddText("Get ready, we want to start the game !!")
         else
            gui.game_lobby.AddText("Host wants to start the game but some players are not ready yet !")
         end
      elseif data_object.action == "update_params" then
         gui.game_lobby.AddText("Game parameters are updated")
         gui.game_lobby.gameplay_cfg = data_object.params
      end
   end
end

function gui.game_lobby.GetReady(ready_button)
   love.audio.play(audio.sounds.menu_click.source)
   if gui.players[1].host then
      gui.game_lobby.Launch()
   else
      gui.players[1].ready = not gui.players[1].ready
      gui.game_lobby.RefreshList()
      gui.game_lobby.synchronize()
      if gui.players[1].ready then
         ready_button:SetText("Not Ready")
      else
         ready_button:SetText("Ready")
      end
   end
end

function gui.game_lobby.Launch(data_object)
   local ishost = gui.players[1].host
   if ishost then
      for i,player in ipairs(gui.players) do
         if not player.ready then
            local msg_object = {action = "get_ready"}
            gui.game_lobby.SendData(msg_object)
            gui.game_lobby.AddText("All players are not ready...")
            return
         end
      end
   end

   timer.removeListener(gui.game_lobby.SendPings)
   timer.removeListener(gui.game_lobby.RefreshPings)
   reseau.removeClientListener(gui.game_lobby.clientListener)
   reseau.removeHostListener(gui.game_lobby.hostListener)

   local player_cfg = {
      role = string.lower(gui.players[1].role),
      network_id = gui.players[1].userid,
      name = gui.players[1].name
   }

   local opponents_cfg = {}
   -- create an opponent entity for each other player in the game
   for i=2,#gui.players do
      local opp = {role = string.lower(gui.players[i].role),
                  name = gui.players[i].name,}
      opp.controller = "network"
      opp.network = {network_id = gui.players[i].userid}
      table.insert(opponents_cfg,opp)
   end

   gui.game_lobby.panel:Remove()
   local map_file = "assets/maps/" .. gui.game_lobby.current_map .. ".lua"
   love.audio.stop(audio.sounds.menu_music)
   audio.LoopMusic(audio.sounds.map_music2)
   gs.switch("jeu/game", map_file, player_cfg, opponents_cfg, data_object, gui.game_lobby.gameplay_cfg)
end

function gui.game_lobby.LeaveLobby()
   love.audio.play(audio.sounds.menu_click.source)
   timer.removeListener(gui.game_lobby.SendPings)
   timer.removeListener(gui.game_lobby.RefreshPings)
   reseau.removeClientListener(gui.game_lobby.clientListener)
   reseau.removeHostListener(gui.game_lobby.hostListener)
   reseau.close()
   gui.game_lobby.panel:Remove()
   gui.main_menu.Load()
end

function gui.game_lobby.ChangeName(textinput)
        if gui.players[1].name ~= textinput:GetText() then
                gui.game_lobby.AddText(gui.players[1].name .. " has changed name to " .. textinput:GetText())
                local data_object = {
                        action = "rename",
                        oldname = gui.players[1].name,
                        newname = textinput:GetText()
                }
                gui.players[1].name = textinput:GetText()
                gui.game_lobby.SendData(data_object)
                gui.game_lobby.RefreshList()
                gui.game_lobby.synchronize()
        end
end

function gui.game_lobby.SendMessage(textinput, message)
        local msg_object = {
                action = "message",
                name = gui.players[1].name,
                text = message
        }
        gui.game_lobby.SendData(msg_object)
        gui.game_lobby.AddText(gui.players[1].name .. ": " .. message)
end

function gui.game_lobby.SendData(data_object)
   if gui.players[1].host then
      reseau.broadcast(data_object)
   else
      local peer = reseau.client:get_peer(1)
      reseau.send(peer, data_object)
   end
end

function gui.game_lobby.AddText(text)
        local current_text = gui.game_lobby.tchat:GetText()
        gui.game_lobby.tchat:SetText(current_text .. "\n" .. text)
end

function gui.game_lobby.RefreshList()
        gui.game_lobby.list:Clear()

        for i, player in ipairs(gui.players) do
                gui.game_lobby.list:AddRow(player.name, player.role, player.ready, player.ping)
        end
end

function gui.game_lobby.GameParams()
   if gui.players[1].host then
      local frame = loveframes.Create("frame")
      frame:SetName("Game parameters")
      frame:SetDockable(false)
      frame:SetScreenLocked(true)
      frame:ShowCloseButton(false)
      frame:SetWidth(430)
      frame:SetHeight(250)
      frame:Center()

      local button = loveframes.Create("button", frame)
      button:SetText("OK")
      button:SetSize(60, 30)
      button:SetPos(360, 210)
      button.OnClick = function()
         gui.game_lobby.SendData({action = "update_params", params = gui.game_lobby.gameplay_cfg})
         button:GetParent():Remove()
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Ghost max barriers")
      gui.game_lobby.map_label:SetPos(10, 35)

      local numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(135, 30)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(10)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.ghost.max_barriers)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.ghost.max_barriers = value
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Sharred barriers")
      gui.game_lobby.map_label:SetPos(10, 68)

      local multichoice = loveframes.Create("multichoice", frame)
      multichoice:SetPos(135, 65)
      multichoice:SetSize(50, 25)
      multichoice:AddChoice("Yes")
      multichoice:AddChoice("No")
      if gui.game_lobby.gameplay_cfg.ghost.shared_barriers then
         multichoice:SetChoice("Yes")
      else
         multichoice:SetChoice("No")
      end
      multichoice.OnChoiceSelected = function(object, choice)
         gui.game_lobby.gameplay_cfg.ghost.shared_barriers = choice == "Yes"
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Ghost build speed")
      gui.game_lobby.map_label:SetPos(10, 103)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(135, 100)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(15)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.ghost.build_speed * 10)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.ghost.build_speed = value / 10
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Ghost destroy speed")
      gui.game_lobby.map_label:SetPos(10, 138)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(135, 135)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(15)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.ghost.destroy_speed * 10)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.ghost.destroy_speed = value / 10
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Ghost move speed")
      gui.game_lobby.map_label:SetPos(10, 173)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(135, 170)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(50)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.ghost.move_force / 1000)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.ghost.move_force = value * 1000
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Game timeout (0 = map default)")
      gui.game_lobby.map_label:SetPos(10, 208)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(205, 205)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(600)
      if gui.game_lobby.gameplay_cfg.game.timeout then
         numberbox:SetValue(gui.game_lobby.gameplay_cfg.game.timeout)
      else
         numberbox:SetValue(0)
      end
      numberbox.OnValueChanged = function(object, value)
         if value == 0 then
            gui.game_lobby.gameplay_cfg.game.timeout = nil
         else
            gui.game_lobby.gameplay_cfg.game.timeout = value
         end
      end
      
      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Hunter detection range")
      gui.game_lobby.map_label:SetPos(210, 35)

      local numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(370, 30)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(100)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.hunter.ghost_detect_dist)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.hunter.ghost_detect_dist = value
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Hunters can kill ghosts")
      gui.game_lobby.map_label:SetPos(210, 68)

      local multichoice = loveframes.Create("multichoice", frame)
      multichoice:SetPos(370, 65)
      multichoice:SetSize(50, 25)
      multichoice:AddChoice("Yes")
      multichoice:AddChoice("No")
      if gui.game_lobby.gameplay_cfg.hunter.can_shoot then
         multichoice:SetChoice("Yes")
      else
         multichoice:SetChoice("No")
      end
      multichoice.OnChoiceSelected = function(object, choice)
         gui.game_lobby.gameplay_cfg.hunter.can_shoot = choice == "Yes"
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Hunter shoot range")
      gui.game_lobby.map_label:SetPos(210, 103)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(370, 100)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(1000)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.hunter.shoot_dist)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.hunter.shoot_dist = value
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Hunter shoot precision")
      gui.game_lobby.map_label:SetPos(210, 138)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(370, 135)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(6)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.hunter.shoot_angle)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.hunter.shoot_angle = value
      end

      gui.game_lobby.map_label = loveframes.Create("text", frame)
      gui.game_lobby.map_label:SetText("Hunter move speed")
      gui.game_lobby.map_label:SetPos(210, 173)

      numberbox = loveframes.Create("numberbox", frame)
      numberbox:SetPos(370, 170)
      numberbox:SetSize(50, 25)
      numberbox:SetMin(0)
      numberbox:SetMax(50)
      numberbox:SetValue(gui.game_lobby.gameplay_cfg.hunter.move_force / 1000)
      numberbox.OnValueChanged = function(object, value)
         gui.game_lobby.gameplay_cfg.hunter.move_force = value * 1000
      end
   else
      gui.game_lobby.AddText("Ghost max barriers :  " .. tostring(gui.game_lobby.gameplay_cfg.ghost.max_barriers))
      gui.game_lobby.AddText("Sharred barriers :  " .. tostring(gui.game_lobby.gameplay_cfg.ghost.shared_barriers))
      gui.game_lobby.AddText("Ghost build speed :  " .. tostring(gui.game_lobby.gameplay_cfg.ghost.build_speed * 10))
      gui.game_lobby.AddText("Ghost destroy speed :  " .. tostring(gui.game_lobby.gameplay_cfg.ghost.destroy_speed * 10))
      gui.game_lobby.AddText("Ghost move speed :  " .. tostring(gui.game_lobby.gameplay_cfg.ghost.move_force / 1000))
      gui.game_lobby.AddText("Hunter detection range :  " .. tostring(gui.game_lobby.gameplay_cfg.hunter.ghost_detect_dist))
      gui.game_lobby.AddText("Hunters can kill ghosts :  " .. tostring(gui.game_lobby.gameplay_cfg.hunter.can_shoot))
      gui.game_lobby.AddText("Hunter shoot range :  " .. tostring(gui.game_lobby.gameplay_cfg.hunter.shoot_dist))
      gui.game_lobby.AddText("Hunter shoot precision :  " .. tostring(gui.game_lobby.gameplay_cfg.hunter.shoot_angle))
      gui.game_lobby.AddText("Hunter move speed :  " .. tostring(gui.game_lobby.gameplay_cfg.hunter.move_force / 1000))
      if gui.game_lobby.gameplay_cfg.game.timeout then
         gui.game_lobby.AddText("Game timeout :  " .. tostring(gui.game_lobby.gameplay_cfg.game.timeout))
      else
         gui.game_lobby.AddText("Game timeout :  Map default")
      end
   end
end

