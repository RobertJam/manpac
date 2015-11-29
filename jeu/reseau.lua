local reseau = {
	hostListeners = {},
	clientListeners = {}
}

function reseau.update(dt)
	if reseau.host then
		local host_event = reseau.host:service()
		if host_event then
			for listener in reseau.hostListeners do
				listener(host_event)
			end
			-- if host_event.type == "receive" then
				-- reseau.host_receive(host_event.data)
			-- elseif host_event.type == "connect" then
				-- reseau.host_connect(host_event.peer)
			-- elseif host_event.type == "disconnect" then
				-- reseau.host_disconnect(host_event.peer)
			-- end
		end
	end

	if reseau.client then
		local client_event = reseau.client:service()
		if client_event then
			for listener in reseau.clientListeners do
				listener(host_event)
			end
			-- if client_event.type == "receive" then
				-- reseau.client_receive(client_event.data)
			-- elseif client_event.type == "connect" then
				-- reseau.client_connect(client_event.peer)
			-- elseif client_event.type == "disconnect" then
				-- reseau.client_disconnect(client_event.peer)
			-- end
		end
	end
end

function reseau.start_server(port)
	reseau.host = enet.host_create("*:950")
end

function reseau.connect(host, port)
	reseau.client = enet.host_create()
	reseau.server = reseau.client:connect(host .. ":" .. port)
end

function reseau.addHostListener(listener)
	table.insert(reseau.hostListeners, listener)
end

function reseau.addClientListener(callback)
	table.insert(reseau.clientListeners, listener)
end

-- function reseau.host_receive(data)

-- end

-- function reseau.host_connect(peer)

-- end

-- function reseau.host_disconnect(peer)

-- end

-- function reseau.client_receive(data)

-- end

-- function reseau.client_connect(peer)

-- end

-- function reseau.client_disconnect(peer)

-- end

return reseau