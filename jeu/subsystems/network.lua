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

function network.exit_system()
        reseau.removeHostListener(network.hostListener)
        reseau.removeClientListener(network.clientListener)
end

function network.init_entity(self,cfg)
   for k,v in pairs(cfg) do
      print(k,v)
   end
   print("Initializing network entity",self._id,cfg.network_id)
   self.network_id = cfg.network_id
   self.network_update = cfg.update or true
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

function network.sendData(data_object, peer)
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
   if msg.action == "entity_position" then
      local ent = network.entities[msg.network_id]
      if not ent then
         print("Unable to find network entity",msg.network_id)
         return
      end
      ent:setPosition(msg.x,msg.y)
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
      network.sendData(entData)
   end
end

return network
