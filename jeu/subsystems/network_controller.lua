-- network player controler

local network = {}

function network.init_entity(self,keymap)

end

function network.update(entities,dt)
end

function network.init_system()
	if reseau.host then
		reseau.addHostListener(network.hostListener)
	elseif reseau.client then
		reseau.addClientListener(network.clientListener)
		local data_object = {
			action = "game_init",
			role = game.player.role,
			name = game.player.name,
			position = game.player:getPosition()
		}
		network.SendData(data_object, peer)
	end
end

function network.hostListener(event)
	if event.type == "connect" then
		network.SendData({action = "server_in_game"}, event.peer)
	elseif event.type == "disconnect" then
		
	elseif event.type == "receive" then
		reseau.dispatch(event)
		network.receiveData(event.dec_data)
	end
end

function network.receiveData(data_object)

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

function network.clientListener(event)
end


function network.exit_system()
	reseau.removeHostListener(network.hostListener)
	reseau.removeClientListener(network.clientListener)
end

return network
