local reseau = {
	hostListeners = {},
	clientListeners = {}
}

function reseau.update(dt)
	if reseau.host then
		local host_event = reseau.host:service()
		if host_event then
			for i,callback in ipairs(reseau.hostListeners) do
				callback(host_event)
			end
		end
	end

	if reseau.client then
		local client_event = reseau.client:service()
		if client_event then
			for i,callback in ipairs(reseau.clientListeners) do
				callback(client_event)
			end
		end
	end
end

function reseau.start_server(port)
	reseau.host = enet.host_create("*:950")
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
		if peer:index() ~= event.peer:index() then
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

function reseau.removeHostListener(id)
	table.remove(reseau.hostListeners, id)
end

function reseau.removeClientListener(id)
	table.remove(reseau.clientListeners, id)
end

return reseau