local gui = require("jeu.gui.main_menu")
require('enet')

gui.game_lobby = {}

function gui.game_lobby.Load()
	loveframes = require("libs.loveframes")

	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	local object_spaing = 20

	gui.game_lobby.panel = loveframes.Create("panel")
	gui.game_lobby.panel = gui.game_lobby.panel:SetSize(width, height)
	gui.game_lobby.panel = gui.game_lobby.panel:SetPos(0, 0)

	gui.game_lobby.list = loveframes.Create("columnlist", gui.game_lobby.panel)
	gui.game_lobby.list:SetPos(5, 5)
	gui.game_lobby.list:SetSize(400, 450)
	gui.game_lobby.list:AddColumn("Player")
	gui.game_lobby.list:AddColumn("Role")
	gui.game_lobby.list:AddColumn("Ready")
	gui.game_lobby.list:AddColumn("Ping")

	local text = loveframes.Create("text", gui.game_lobby.panel)
	text:SetText("Name")
	text:SetPos(5, 468)
	text:SetSize(30, 15)

	local textinput = loveframes.Create("textinput", gui.game_lobby.panel)
	textinput:SetPos(50, 460)
	textinput:SetSize(355, 30)
	textinput:SetText("Unknown")
	textinput.OnEnter = gui.game_lobby.ChangeName
	textinput.OnFocusLost = gui.game_lobby.ChangeName

	text = loveframes.Create("text", gui.game_lobby.panel)
	text:SetText("Role")
	text:SetPos(5, 515)
	text:SetSize(30, 15)

	local multichoice = loveframes.Create("multichoice", frame)
	multichoice:SetPos(50, 505)
	multichoice:SetSize(355, 30)
	multichoice:AddChoice("Ghost")
	multichoice:AddChoice("Hunter")
	multichoice.OnChoiceSelected = function()
		gui.players[1].role = multichoice:GetChoice()
		gui.game_lobby.RefreshList()
		gui.game_lobby.synchronize()
	end

	gui.game_lobby.tchat = loveframes.Create("textinput", gui.game_lobby.panel)
	gui.game_lobby.tchat:SetPos(415, 5)
	gui.game_lobby.tchat:SetSize(380, 450)
	gui.game_lobby.tchat:SetMultiline(true)
	gui.game_lobby.tchat:SetEditable(false)
	gui.game_lobby.tchat:ShowLineNumbers(false)
	gui.game_lobby.tchat:SetFont(love.graphics.newFont(12))

	local textinput = loveframes.Create("textinput", gui.game_lobby.panel)
	textinput:SetPos(415, 460)
	textinput:SetSize(380, 30)
	textinput.OnEnter = gui.game_lobby.SendMessage

	local ready_button = loveframes.Create("button", gui.game_lobby.panel)
	ready_button:SetSize(150, 30)
	ready_button:SetPos(645, 505)
	ready_button:SetText("Ready")
	ready_button.OnClick = gui.game_lobby.GetReady

	local leave_button = loveframes.Create("button", gui.game_lobby.panel)
	leave_button:SetSize(150, 30)
	leave_button:SetPos(490, 505)
	leave_button:SetText("Leave")
	leave_button.OnClick = gui.game_lobby.LeaveLobby

	if gui.players[1].host then
		reseau.addHostListener(gui.game_lobby.hostListener)
		reseau.start_server(950)
		gui.game_lobby.AddText("Server started on port 950")
	else
		reseau.addClientListener(gui.game_lobby.clientListener)
		gui.game_lobby.AddText("Connected to " .. reseau.hostname)
	end
	gui.game_lobby.RefreshList()
end

function gui.game_lobby.getPlayerIndex(peer_index)
	for i,player in ipairs(gui.players) do
		if gui.players[i].userid == peer_index then
			return i
		end
	end
	return -1
end

function gui.game_lobby.hostListener(event)
	if event.type == "connect" then
		gui.game_lobby.newPlayer(event.peer)
	elseif event.type == "disconnect" then
		gui.game_lobby.disconnectedPlayer(event.peer:index())
	elseif event.type == "receive" then
		if event.dec_data and event.dec_data.action ~= "synchronize" then
			reseau.dispatch(event)
		end
		gui.game_lobby.receiveData(event.dec_data)
	end
end

function gui.game_lobby.disconnectedPlayer(peer_index)
	local player_index = gui.game_lobby.getPlayerIndex(peer_index)
	gui.game_lobby.AddText(gui.players[player_index].name .. " has left the lobby")
	reseau.disconnect_peer(peer_index)

	local data_object = {
		action = "disconnect_player",
		player_id = peer_index
	}
	gui.game_lobby.SendData(data_object)gui.game_lobby.removePlayer(player_index)
end

function gui.game_lobby.removePlayer(player_index)
	table.remove(gui.players, player_index)
	gui.game_lobby.RefreshList()
end

function gui.game_lobby.newPlayer(peer)
	gui.game_lobby.AddText("A new player has entered the game")
	local data_object = {
		action = "init_id",
		value = peer:index()
	}

	reseau.send(peer, data_object)
	
	local new_player = {
		name = "Unknown",
		role = "Ghost",
		userid = peer:index(),
		ready = false,
		ping = 0,
		host = false
	}
	table.insert(gui.players, new_player)
	
	gui.game_lobby.synchronize()
	gui.game_lobby.RefreshList()
end

function gui.game_lobby.synchronize()
	local data_object = {action = "synchronize"}
	if gui.players[1].host then
		data_object.players = gui.players
	else
		data_object.players = gui.players[1]
	end
	gui.game_lobby.SendData(data_object)
end

function gui.game_lobby.clientListener(event)
	if event.type == "receive" then
		print(tostring(event.data))
		gui.game_lobby.receiveData(event.dec_data)
	end
end

function gui.game_lobby.receiveData(data_object)
	if data_object.action then
		if data_object.action == "message" then
			gui.game_lobby.AddText(data_object.name .. ": " .. data_object.text)
		elseif data_object.action == "rename" then
			gui.game_lobby.AddText(data_object.oldname .. " has changed name to " .. data_object.newname)
		elseif data_object.action == "init_id" then
			gui.players[1].userid = data_object.value
		elseif data_object.action == "disconnect_player" then
			local player_index = gui.game_lobby.getPlayerIndex(data_object.player_id)
			gui.game_lobby.AddText(gui.players[player_index].name .. " has left the lobby")
			gui.game_lobby.removePlayer(player_index)
		elseif data_object.action == "synchronize" then
			if gui.players[1].host then
				for i,player in ipairs(gui.players) do
					if data_object.players.userid == gui.players[i].userid then
						gui.players[i] = data_object.players
					end
				end
				gui.game_lobby.synchronize()
			else
				while table.getn(gui.players) > 1 do
					table.remove(gui.players)
				end
				for i,player in ipairs(data_object.players) do
					if data_object.players[i].userid ~= gui.players[1].userid then
						table.insert(gui.players, data_object.players[i])
					end
				end
			end
			gui.game_lobby.RefreshList()
		end
	end
end

function gui.game_lobby.GetReady()
	gui.players[1].ready = not gui.players[1].ready
	gui.game_lobby.RefreshList()
	gui.game_lobby.synchronize()
end

function gui.game_lobby.LeaveLobby()
	reseau.removeClientListener(gui.game_lobby.clientListener)
	reseau.removeHostListener(gui.game_lobby.hostListener)
	reseau.close()
	gui.game_lobby.panel:Remove()
	gui.main_menu.Load()
end

function gui.game_lobby.ChangeName(textinput)
	if gui.players[1].name ~= textinput:GetText() then
		gui.game_lobby.AddText(gui.players[1].name .. " has changed name to " .. textinput:GetText())
		local data_object = {
			action = "rename",
			oldname = gui.players[1].name,
			newname = textinput:GetText()
		}
		gui.players[1].name = textinput:GetText()
		gui.game_lobby.SendData(data_object)
		gui.game_lobby.RefreshList()
		gui.game_lobby.synchronize()
	end
end

function gui.game_lobby.SendMessage(textinput, message)
	local msg_object = {
		action = "message",
		name = gui.players[1].name,
		text = message
	}
	gui.game_lobby.SendData(msg_object)
	gui.game_lobby.AddText(gui.players[1].name .. ": " .. message)
end

function gui.game_lobby.SendData(data_object)
	if gui.players[1].host then
		reseau.broadcast(data_object)
	else
		local peer = reseau.client:get_peer(1)
		reseau.send(peer, data_object)
	end
end

function gui.game_lobby.AddText(text)
	local current_text = gui.game_lobby.tchat:GetText()
	gui.game_lobby.tchat:SetText(current_text .. "\n" .. text)
end

function gui.game_lobby.RefreshList()
	gui.game_lobby.list:Clear()
	
	for i, player in ipairs(gui.players) do
		gui.game_lobby.list:AddRow(player.name, player.role, player.ready, player.ping)
	end
end

return gui