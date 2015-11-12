main_menu = {}
main_menu.panel = nil

function main_menu.Load()
	loveframes = require("libs.loveframes")
	require("libs.gui.join_menu")
	
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	
	local button_spaing = 20
	
	main_menu.panel = loveframes.Create("panel")
	main_menu.panel = main_menu.panel:SetSize(width, height)
	main_menu.panel = main_menu.panel:SetPos(0, 0)
	
	local host_button = loveframes.Create("button", main_menu.panel)
	host_button:SetSize(200, 30)
	host_button:SetPos(width / 2 - 100, height / 2 - 30 - button_spaing / 2)
	host_button:SetText("Host a game")
	host_button.OnClick = main_menu.HostGame
	
	local join_button = loveframes.Create("button", main_menu.panel)
	join_button:SetSize(200, 30)
	join_button:SetPos(width / 2 - 100, height / 2 + button_spaing / 2)
	join_button:SetText("Join a game")
	join_button.OnClick = main_menu.JoinGame
end

function main_menu.HostGame()
	main_menu.panel.visible = false
end

function main_menu.JoinGame()
	main_menu.panel:Remove()
	join_menu.Load()
end

main_menu.Load()