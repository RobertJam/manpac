-- network player controler

local network_manager = {}

function network_manager.init_system()
	if reseau.host then
		reseau.addHostListener(network_manager.hostListener)
	elseif reseau.client then
		reseau.addClientListener(network_manager.clientListener)
		local data_object = {
			action = "game_init",
			role = game.player.role,
			name = game.player.name,
			position = game.player:getPosition()
		}
		network_manager.SendData(data_object, peer)
	end
end

function network_manager.hostListener(event)
	if event.type == "connect" then
		network_manager.SendData({action = "server_in_game"}, event.peer)
	elseif event.type == "disconnect" then
		
	elseif event.type == "receive" then
		reseau.dispatch(event)
		network_manager.receiveData(event.dec_data)
	end
end

function network_manager.receiveData(data_object)

end

function network_manager.SendData(data_object, peer)
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

function network_manager.clientListener(event)
end


function network_manager.exit_system()
	reseau.removeHostListener(network_manager.hostListener)
	reseau.removeClientListener(network_manager.clientListener)
end

return network_manager
