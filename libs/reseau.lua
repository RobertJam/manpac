local reseau = {
   hostListeners = {},
   clientListeners = {}
}

require('enet')
reseau.json = require('libs/json')

function reseau.update(dt)
   if reseau.host then
      local host_event = reseau.host:service()
      if host_event then
         if host_event.type == "receive" then
            local enc_data = tostring(host_event.data)
            host_event.dec_data = reseau.json.decode(enc_data)
         end
         for i,callback in ipairs(reseau.hostListeners) do
            callback(host_event)
         end
      end
   end

   if reseau.client then
      local client_event = reseau.client:service()
      if client_event then
         local notify_client = true
         if client_event.type == "receive" then
            local enc_data = tostring(client_event.data)
            client_event.dec_data = reseau.json.decode(enc_data)
         end
         for i,callback in ipairs(reseau.clientListeners) do
            callback(client_event)
         end
      end
   end
end

function reseau.disconnect_peer(peer_index)
   local peer = reseau.host:get_peer(peer_index)
   peer:disconnect()
end

function reseau.send(peer, data)
   local enc_data = reseau.json.encode(data)
   peer:send(enc_data)
end

function reseau.broadcast(data)
   local enc_data = reseau.json.encode(data)
   reseau.host:broadcast(enc_data)
end

function reseau.start_server(port)
   reseau.host = enet.host_create("*:" .. port)
   reseau.timer = love.timer.getTime()
end

function reseau.connect(host, port)
   reseau.hostname = host
   reseau.client = enet.host_create()
   reseau.server = reseau.client:connect(host .. ":" .. port)
end

function reseau.close()
   reseau.hostname = nil
   if reseau.server then
      reseau.server:disconnect()
      reseau.server = nil
   end
   if reseau.client then
      reseau.client:flush()
      reseau.client = nil
   end
   if reseau.host then
      for i=1, reseau.host:peer_count() do
         local peer = reseau.host:get_peer(i)
         peer:disconnect()
      end
      reseau.host:flush()
      reseau.host:destroy()
      reseau.host = nil
   end
end

function reseau.dispatch(event)
   for i=1, reseau.host:peer_count() do
      local peer = reseau.host:get_peer(i)
      if peer:state() == "connected" and peer:index() ~= event.peer:index() then
         peer:send(event.data)
      end
   end
end

function reseau.addHostListener(listener)
   table.insert(reseau.hostListeners, listener)
   return table.getn(reseau.hostListeners)
end

function reseau.addClientListener(listener)
   table.insert(reseau.clientListeners, listener)
   return table.getn(reseau.clientListeners)
end

function reseau.removeHostListener(listener)
   for i,callback in ipairs(reseau.hostListeners) do
      if callback == listener then
         table.remove(reseau.hostListeners, i)
         return
      end
   end
end

function reseau.removeClientListener(listener)
   for i,callback in ipairs(reseau.clientListeners) do
      if callback == listener then
         table.remove(reseau.clientListeners, i)
         return
      end
   end
end

return reseau
