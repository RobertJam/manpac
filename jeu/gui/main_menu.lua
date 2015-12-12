local gui = {
	players = {}
}

gui.main_menu = {
	panel = nil
}

function gui.main_menu.Load()
	loveframes = require("libs.loveframes")
	
	loveframes.util.SetActiveSkin("Dark")
	
	require("jeu.gui.join_menu")
	require("jeu.gui.game_lobby")
	
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	
	gui.players[1] = {
		name = "Unknown",
		role = "Hunter",
		userid = 0,
		controller = "network",
		ready = false,
		ping = 0,
		host = false
	}
	
	local button_spaing = 20
	
	gui.main_menu.panel = loveframes.Create("panel")
	gui.main_menu.panel = gui.main_menu.panel:SetSize(width, height)
	gui.main_menu.panel = gui.main_menu.panel:SetPos(0, 0)
	
	local host_button = loveframes.Create("button", gui.main_menu.panel)
	host_button:SetSize(200, 30)
	host_button:SetPos(width / 2 - 100, height / 2 - 30 - button_spaing / 2)
	host_button:SetText("Host a game")
	host_button.OnClick = gui.main_menu.HostGame
	
	local join_button = loveframes.Create("button", gui.main_menu.panel)
	join_button:SetSize(200, 30)
	join_button:SetPos(width / 2 - 100, height / 2 + button_spaing / 2)
	join_button:SetText("Join a game")
	join_button.OnClick = gui.main_menu.JoinGame
	
	local quick_button = loveframes.Create("button", gui.main_menu.panel)
	quick_button:SetSize(200, 30)
	quick_button:SetPos(width / 2 - 100, height / 2 + 60)
	quick_button:SetText("Quick Start")
	quick_button.OnClick = gui.main_menu.QuickStart
end

function gui.main_menu.HostGame()
	gui.players[1].host = true
	gui.main_menu.panel:Remove()
	gui.game_lobby.Load()
end

function gui.main_menu.JoinGame()
	gui.main_menu.panel:Remove()
	gui.join_menu.Load()
end

function gui.main_menu.QuickStart()
	gui.main_menu.panel:Remove()
	gs.switch("jeu/game")
end

return gui