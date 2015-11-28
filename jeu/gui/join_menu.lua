local gui = require("jeu.gui.main_menu")

gui.join_menu = {
	panel = nil
}

function gui.join_menu.Load()
	loveframes = require("libs.loveframes")
	
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	
	local object_spaing = 20
	
	gui.join_menu.panel = loveframes.Create("panel")
	gui.join_menu.panel = gui.join_menu.panel:SetSize(width, height)
	gui.join_menu.panel = gui.join_menu.panel:SetPos(0, 0)
	
	local text = loveframes.Create("text", gui.join_menu.panel)
	text:SetText("Adresse IP")
	text:SetPos(width / 2 - 100, height / 2 - 30 - 60)
	text:SetSize(200, 30)
	
	local textinput = loveframes.Create("textinput", gui.join_menu.panel)
	textinput:SetPos(width / 2 - 100, height / 2 - 15 - object_spaing - 30)
	textinput:SetSize(200, 30)
	textinput:SetText("127.0.0.1")
	textinput.OnEnter = Connect
	textinput:SetFont(love.graphics.newFont(12))

	local connect_button = loveframes.Create("button", gui.join_menu.panel)
	connect_button:SetSize(200, 30)
	connect_button:SetPos(width / 2 - 100, height / 2 - 15)
	connect_button:SetText("Connect")
	connect_button.OnClick =gui. join_menu.Connect

	local cancel_button = loveframes.Create("button", gui.join_menu.panel)
	cancel_button:SetSize(200, 30)
	cancel_button:SetPos(width / 2 - 100, height / 2 - 15 + object_spaing + 30)
	cancel_button:SetText("Cancel")
	cancel_button.OnClick = gui.join_menu.Cancel
end

function gui.join_menu.Cancel()
	gui.join_menu.panel:Remove()
	gui.main_menu.Load()
end

function gui.join_menu.Connect(connect_button)
	connect_button:SetEnabled(false)
end

return gui