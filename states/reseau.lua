local state = {}


local loveframes = require("libs.loveframes")
require('enet')

function state.enter()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	state.panel_host = loveframes.Create("panel")
	state.panel_host = state.panel_host:SetSize(width / 2, height)
	state.panel_host = state.panel_host:SetPos(0, 0)

	state.panel_client = loveframes.Create("panel")
	state.panel_client = state.panel_client:SetSize(width / 2, height)
	state.panel_client = state.panel_client:SetPos(width / 2, 0)

	local host_header = loveframes.Create("text", state.panel_host)
	host_header:SetText("Server")
	host_header:SetPos(width / 4 - 25, 15)
	host_header:SetSize(50, 15)

	local client_header = loveframes.Create("text", state.panel_client)
	client_header:SetText("Client")
	client_header:SetPos(width / 4 - 25, 15)
	client_header:SetSize(50, 15)

	state.host_tchat = loveframes.Create("textinput", state.panel_host)
	state.host_tchat:SetPos(width / 4 - 150, 50)
	state.host_tchat:SetSize(300, 350)
	state.host_tchat:SetMultiline(true)
	state.host_tchat:SetEditable(false)
	state.host_tchat:ShowLineNumbers(false)

	state.client_tchat = loveframes.Create("textinput", state.panel_client)
	state.client_tchat:SetPos(width / 4 - 150, 50)
	state.client_tchat:SetSize(300, 350)
	state.client_tchat:SetMultiline(true)
	state.client_tchat:SetEditable(false)
	state.client_tchat:ShowLineNumbers(false)

	local host_input = loveframes.Create("textinput", state.panel_host)
	host_input:SetPos(width / 4 - 150, 405)
	host_input:SetSize(300, 30)
	host_input.OnEnter = state.HostSendMessage

	local client_input = loveframes.Create("textinput", state.panel_client)
	client_input:SetPos(width / 4 - 150, 405)
	client_input:SetSize(300, 30)
	client_input.OnEnter = state.ClientSendMessage

	local host_button = loveframes.Create("button", state.panel_host)
	host_button:SetSize(150, 30)
	host_button:SetPos(width / 4 - 150, 450)
	host_button:SetText("Start Host")
	host_button.OnClick = state.HostButtonClick

	local client_button = loveframes.Create("button", state.panel_client)
	client_button:SetSize(150, 30)
	client_button:SetPos(width / 4 - 150, 450)
	client_button:SetText("Connect")
	client_button.OnClick = state.ClientButtonClick
end

function state.HostSendMessage(textinput)
	if state.host then
		local message = textinput:GetText()
		state.host:broadcast(message)
		textinput:SetText("")
	end
end

function state.ClientSendMessage(textinput)
	if state.client then
		local message = textinput:GetText()
		local peer = state.client:get_peer(1)
		peer:send(message)
		textinput:SetText("")
	end
end

function state.HostButtonClick(host_button)
	if host_button:GetText() == "Start Host" then
		state.host = enet.host_create("localhost:950")
		state.WriteToHost("Server Listening on port 950\n")
		host_button:SetText("Stop Host")
	else
		state.host:flush()
		state.host:destroy()
		state.host = nil
		state.WriteToHost("Server stopped\n")
		host_button:SetText("Start Host")
	end
end

function state.ClientButtonClick(client_button)
	if client_button:GetText() == "Connect" then
		state.client = enet.host_create()
		state.server = state.client:connect("localhost:950")
		client_button:SetText("Disconnect")
	else
		state.server:disconnect()
		state.client:flush()
		state.client = nil
		client_button:SetText("Connect")
	end
end

function state.ClientRecieve(data)
	state.WriteToHost(data)
end

function state.WriteToHost(text)
	local current_text = state.host_tchat:GetText()
	state.host_tchat:SetText(current_text .. text .. "\n")
end

function state.WriteToClient(text)
	local current_text = state.client_tchat:GetText()
	state.client_tchat:SetText(current_text .. text .. "\n")
end

function state.update(dt)
	loveframes.update(dt)

	local message = nil
	if state.host then
		local host_event = state.host:service()
		if host_event then
			if host_event.type == "receive" then
				message = "Got message: " .. host_event.data
			elseif host_event.type == "connect" then
				message =  tostring(host_event.peer) .. " has entered the room."
			elseif host_event.type == "disconnect" then
				message =  tostring(host_event.peer) .. " has disconnected."
			end
			if message then
				state.WriteToHost(message .. "\n")
			end
		end
	end
	
	message = nil
	if state.client then
		local client_event = state.client:service()
		if client_event then
			if client_event.type == "connect" then
				message = "Connected to " .. tostring(client_event.peer)
			elseif client_event.type == "receive" then
				message = "Got message: " .. client_event.data
			elseif client_event.type == "disconnect" then
				message =  tostring(client_event.peer) .. " has closed connection."
			end
			if message then
				state.WriteToClient(message .. "\n")
			end
		end
	end
end

function state.draw()
	loveframes.draw()
end

function state.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function state.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function state.keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end

function state.keyreleased(key)
	loveframes.keyreleased(key)
end

function state.textinput(text)
	loveframes.textinput(text)
end





return state