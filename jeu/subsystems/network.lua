-- network subsystem

local network = {
   entities = {},    -- network_id -> entity table for all network controlled entities
   network_id = -1,  -- game instance network id
}

function network.init_system()
   if reseau.host then
      reseau.addHostListener(network.hostListener)
   elseif reseau.client then
      reseau.addClientListener(network.clientListener)
   end
end

function network.exit_system()
        reseau.removeHostListener(network.hostListener)
        reseau.removeClientListener(network.clientListener)
end

function network.init_entity(self,cfg)
   self.network_id = cfg.network_id
   network.entities[self.network_id] = self
end

function network.release_entity(self)
   network.entities[self.network_id] = nil
end

function network.hostListener(event)
   if event.type == "connect" then
      network.SendData({action = "server_in_game"}, event.peer)
   elseif event.type == "disconnect" then
      -- FIXME: handle client disconnection
   elseif event.type == "receive" then
      reseau.dispatch(event)
      network.receiveData(event.dec_data)
   end
end

function network.clientListener(event)
   if event.type == "disconnect" then
      -- FIXME: handle server disconnection
   elseif event.type == "receive" then
      network.receiveData(event.dec_data)
   end
end

function network.SendData(data_object, peer)
   if peer then
      reseau.send(peer, data_object)
   else
      if reseau.host then
         reseau.broadcast(data_object)
      else
         local peer = reseau.client:get_peer(1)
         reseau.send(peer, data_object)
      end
   end
end

function network.receiveData(msg)
   if msg.action == "entity_update" then
      local ent = network.entities[msg.network_id]
      ent:setPosition(msg.x,msg.y)
   else
      print("Unhandled network message received:",msg.action)
   end
end

function network.send_state(entities)
   if network.network_id == -1 then return end
   for ent,_ in pairs(entities) do
      -- send entity state update to others
      local entData = {action = "entity_update",
                       network_id = network.network_id,
                       x = ent.x,
                       y = ent.y,}
      network.sendData(entData)
   end
end

return network
