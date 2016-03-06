local gui = {
	players = {},
	map = nil
}

gui.main_menu = {
	panel = nil
}

function gui.main_menu.Load()
	loveframes = require("libs.loveframes")
	
	-- default font
	local font_default = love.graphics.newFont('assets/fonts/Xolonium-Regular.otf', 16)
	-- title font
	local font_title = love.graphics.newFont('assets/fonts/Xolonium-Bold.otf', 96)
	-- button font
	local font_title = love.graphics.newFont('assets/fonts/Xolonium-Bold.otf', 96)
	-- love.graphics.setFont(font_default)
	
	loveframes.util.SetActiveSkin("Dark")
	
	require("jeu.gui.join_menu")
	require("jeu.gui.game_lobby")
	require("jeu.gui.quick_start")
	
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
	
	local button_spacing = 60
	
	gui.main_menu.panel = loveframes.Create("panel")
	gui.main_menu.panel = gui.main_menu.panel:SetSize(width, height)
	gui.main_menu.panel = gui.main_menu.panel:SetPos(0, 0)

	local buttons_x_origin = 300
	local buttons_y_origin = height / 6

    -- Game title
    local image = loveframes.Create("image", frame)
	image:SetImage("assets/images/title.png")
	image:SetPos(buttons_x_origin - 70, buttons_y_origin - 60)
	image:SetScale(1.2)
	
	local host_button = loveframes.Create("button", gui.main_menu.panel)
	host_button:SetSize(200, 30)
	host_button:SetPos(buttons_x_origin, buttons_y_origin + button_spacing)
	host_button:SetText("Host a game")
	host_button.OnClick = gui.main_menu.HostGame
	
	local join_button = loveframes.Create("button", gui.main_menu.panel)
	join_button:SetSize(200, 30)
	join_button:SetPos(buttons_x_origin, buttons_y_origin + button_spacing * 2)
	join_button:SetText("Join a game")
	join_button.OnClick = gui.main_menu.JoinGame
	
	local quick_button = loveframes.Create("button", gui.main_menu.panel)
	quick_button:SetSize(200, 30)
	quick_button:SetPos(buttons_x_origin, buttons_y_origin + button_spacing * 3)
	quick_button:SetText("Quick Start")
	quick_button.OnClick = gui.main_menu.QuickStart

	local text_shortcuts = loveframes.Create("text", gui.main_menu.panel)
	text_shortcuts:SetSize(640, 30)
	text_shortcuts:SetPos(buttons_x_origin-170, buttons_y_origin + button_spacing * 4)
	text_shortcuts:SetFont(font_default)
	text_shortcuts:SetShadow(true)
	text_shortcuts:SetLinksEnabled(true)
	text_shortcuts:SetDetectLinks(true)
	text_shortcuts:SetDefaultColor(162, 206, 202, 255)
	text_shortcuts:SetShadowColor(34, 37, 46, 255)
	text_shortcuts:SetText("                                    -- Hunters --\n"..
		"       Your goal: look for the exit and escape altogether. \n"..
		"   You can destroy barriers (V key) and attack the ghost... \n"..
		"                        if you find him ! (V key)\n"..
		"\n"..
		"                                     -- Ghost --\n"..
        "      Your goal: survive and don't let the hunters escape. \n"..		
		"Put one of your 3 barriers in their ways to block them (C key) \n"..
		"                  and remove them when needed (V key)\n"..
		"\n"..
		"        ESC: Exit  -  F5: Reload map  -  F6: Reload game\n"..
		"\n"..
		"               https://github.com/RobertJam/manpac")
end

function gui.main_menu.HostGame()
   love.audio.play(audio.sounds.menu_click)
	gui.players[1].host = true
	gui.main_menu.panel:Remove()
	gui.game_lobby.Load()
end

function gui.main_menu.JoinGame()
   love.audio.play(audio.sounds.menu_click)
	gui.main_menu.panel:Remove()
	gui.join_menu.Load()
end

function gui.main_menu.QuickStart()
   love.audio.play(audio.sounds.menu_click)
	gui.main_menu.panel:Remove()
	gui.quick_start.Load()
end

return gui