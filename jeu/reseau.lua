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
				callback(host_event)
			end
		end
	end
end

function reseau.start_server(port)
	reseau.host = enet.host_create("*:950")
end

function reseau.connect(host, port)
	reseau.client = enet.host_create()
	print(host)
	reseau.server = reseau.client:connect(host .. ":" .. port)
end

function reseau.addHostListener(listener)
	table.insert(reseau.hostListeners, listener)
end

function reseau.addClientListener(listener)
	table.insert(reseau.clientListeners, listener)
end

return reseau