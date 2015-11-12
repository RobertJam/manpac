game_lobby = {}

game_lobby.panel = nil
join_menu.cancel_button = nil

function game_lobby.Load()
	loveframes = require("libs.loveframes")
	
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	
	local object_spaing = 20
	
	game_lobby.panel = loveframes.Create("panel")
	game_lobby.panel = game_lobby.panel:SetSize(width, height)
	game_lobby.panel = game_lobby.panel:SetPos(0, 0)
	
	-- local text = loveframes.Create("text", join_menu.panel)
	-- text:SetText("Adresse IP")
	-- text:SetPos(width / 2 - 100, height / 2 - 30 - 60)
	-- text:SetSize(200, 30)
	
	-- local textinput = loveframes.Create("textinput", join_menu.panel)
	-- textinput:SetPos(width / 2 - 100, height / 2 - 15 - object_spaing - 30)
	-- textinput:SetSize(200, 30)
	-- textinput:SetText("127.0.0.1")
	-- textinput.OnEnter = Connect
	-- textinput:SetFont(love.graphics.newFont(12))

	-- local connect_button = loveframes.Create("button", join_menu.panel)
	-- connect_button:SetSize(200, 30)
	-- connect_button:SetPos(width / 2 - 100, height / 2 - 15)
	-- connect_button:SetText("Connect")
	-- connect_button.OnClick = join_menu.Connect

	-- local cancel_button = loveframes.Create("button", join_menu.panel)
	-- cancel_button:SetSize(200, 30)
	-- cancel_button:SetPos(width / 2 - 100, height / 2 - 15 + object_spaing + 30)
	-- cancel_button:SetText("Cancel")
	-- cancel_button.OnClick = join_menu.Cancel
end

function game_lobby.Cancel()
	join_menu.panel:Remove()
	main_menu.Load()
end
