-- network subsystem

local network = {
   entities = {},    -- network_id -> entity table for all network controlled entities
}

function network.init_system()
   if reseau.host then
      reseau.addHostListener(network.hostListener)
   elseif reseau.client then
      reseau.addClientListener(network.clientListener)
   end
end

function network.StartGame()
	if reseau.host then
   
      -- Création de la table des openents
      local openents = systems.network:getEntities()
      local all_players = {}
      for i=1,#openents do
         openent_data = {x = openents[i].x,
                         y = openents[i].y,
                         network_id = openents[i].network_id}
         table.insert(all_players, openent_data)
      end
      
      local host_data = {x = game.player.x,
                         y = game.player.y,
                         network_id = game.player.network_id}
      table.insert(all_players, host_data)
      
      local exit_list = systems.exit:getEntities()
      local all_exit = {}
      for i=1,#exit_list do
         table.insert(all_exit, {x = exit_list[i].x,
                                 y = exit_list[i].y,
                                 width = exit_list[i].shape_width,
                                 height = exit_list[i].shape_height})
      end
      
		local data_object = {action = "launch",
                           entities = all_players,
                           exits = all_exit}
		gui.game_lobby.SendData(data_object)
	end
end

function network.exit_system()
        reseau.removeHostListener(network.hostListener)
        reseau.removeClientListener(network.clientListener)
end

function network.init_entity(self,cfg)
   for k,v in pairs(cfg) do
      print(k,v)
   end
   print("Initializing network entity",self.name,cfg.network_id)
   self.network_id = cfg.network_id
   self.network_update = cfg.update or true
   network.entities[self.network_id] = self
end

function network.release_entity(self)
   network.entities[self.network_id] = nil
end

function network.hostListener(event)
   if event.type == "connect" then
      network.sendData({action = "server_in_game"}, event.peer)
   elseif event.type == "disconnect" then
      reseau.disconnect_peer(event.peer:index())
      local ent = network.entities[event.peer:index()]
      if ent then
         game.kill_entity(ent)
         network.sendData({action = "player_disonnected", network_id = event.peer:index()})
      end
   elseif event.type == "receive" then
      reseau.dispatch(event)
      network.receiveData(event.dec_data)
   end
end

function network.clientListener(event)
   if event.type == "disconnect" then
      gs.switch("jeu/game_over", "disconnected")
   elseif event.type == "receive" then
      network.receiveData(event.dec_data)
   end
end

function network.sendData(data_object, peer)
   if peer then
      reseau.send(peer, data_object)
   else
      if reseau.host then
         reseau.broadcast(data_object)
      elseif reseau.client then
         local peer = reseau.client:get_peer(1)
         reseau.send(peer, data_object)
      end
   end
end

function network.receiveData(msg)
   if msg.action == "entity_position" then
      local ent = network.entities[msg.network_id]
      if not ent then
         -- print("Unable to find network entity",msg.network_id)
         return
      end
      -- print("Received position of",ent.name,ent.network_id,msg.x,msg.y)
      ent:setPosition(msg.x,msg.y)
   elseif msg.action == "player_disonnected" then
      local ent = network.entities[msg.network_id]
      game.kill_entity(ent)
   elseif msg.action == "build_barrier" then
      print("Reveived barrier update",msg.state)
      local bar = systems.barrier.find(msg.x , msg.y)
      if bar then
         bar:set_state(msg.state)
      end
   elseif msg.action == "create_barrier" then
      systems.barrier.create(self, msg.x , msg.y)
   elseif msg.action == "destroy_barrier" then
      local bar = systems.barrier.find(msg.x , msg.y)
      if bar then
         game.kill_entity(bar)
         love.audio.play(audio.sounds.fantome_recupere_barriere)
      end
   elseif msg.action == "game_over" then
      if game.player:hasSystem(msg.win_team) then
         gs.switch("jeu/game_over",true)
      else
         gs.switch("jeu/game_over",false)
      end
   else
      print("Unhandled network message received:",msg.action)
   end
end

function network.send_state(entities)
   for _,ent in pairs(entities) do
      -- send entity state update to others
      local entData = {action = "entity_position",
                       network_id = ent.network_id,
                       x = ent.x,
                       y = ent.y,}
      -- print("Sending position of",ent.name,ent.x,ent.y)
      network.sendData(entData)
   end
end

-- FIXME: should be changed if we remove network.entities list
function network.find_entity(network_id)
   return network.entities[network_id]
end

return network
