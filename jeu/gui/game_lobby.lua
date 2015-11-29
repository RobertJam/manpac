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

function gui.game_lobby.hostListener(event)
	if event.type == "connect" then
		gui.game_lobby.AddText(tostring(event.peer) .. " has entered the game")
	elseif event.type == "receive" then
		reseau.dispatch(event)
		gui.game_lobby.AddText(tostring(event.data))
	end
end

function gui.game_lobby.clientListener(event)
	if event.type == "receive" then
		gui.game_lobby.AddText(tostring(event.data))
	end
end

function gui.game_lobby.GetReady()
	gui.players[1].ready = not gui.players[1].ready
	gui.game_lobby.RefreshList()
end

function gui.game_lobby.LeaveLobby()
	reseau.close()
	gui.game_lobby.panel:Remove()
	gui.main_menu.Load()
end

function gui.game_lobby.ChangeName(textinput)
	if gui.players[1].name ~= textinput:GetText() then
		gui.game_lobby.SendMessage(textinput, gui.players[1].name .. " Nouveau nom => " .. textinput:GetText())
		gui.players[1].name = textinput:GetText()
		gui.game_lobby.RefreshList()
	end
end

function gui.game_lobby.SendMessage(textinput, message)
	message = gui.players[1].name .. ": " .. message
	if gui.players[1].host then
		reseau.host:broadcast(message)
	else
		local peer = reseau.client:get_peer(1)
		peer:send(message)
	end
	gui.game_lobby.AddText(message)
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