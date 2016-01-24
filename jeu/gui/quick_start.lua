local gui = require("jeu.gui.main_menu")

gui.quick_start = {
	panel = nil
}

function gui.quick_start.Load()
	loveframes = require("libs.loveframes")
	
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	
	local object_spaing = 20
	
	gui.quick_start.panel = loveframes.Create("panel")
	gui.quick_start.panel = gui.quick_start.panel:SetSize(width, height)
	gui.quick_start.panel = gui.quick_start.panel:SetPos(0, 0)
	
	local multichoice = loveframes.Create("multichoice", frame)
        multichoice:SetSize(200, 30)
		multichoice:SetPos(width / 2 - 100, height / 2 - 15 - object_spaing - 30)
        multichoice:AddChoice("sewers")
        multichoice:AddChoice("map_V4")
        multichoice.OnChoiceSelected = function()
			gui.map = "assets/maps/" .. multichoice:GetChoice() .. ".lua"
	end

	local start_button = loveframes.Create("button", gui.quick_start.panel)
	start_button:SetSize(200, 30)
	start_button:SetPos(width / 2 - 100, height / 2 - 15)
	start_button:SetText("Play")
	start_button.OnClick = gui.quick_start.Launch

	local cancel_button = loveframes.Create("button", gui.quick_start.panel)
	cancel_button:SetSize(200, 30)
	cancel_button:SetPos(width / 2 - 100, height / 2 - 15 + object_spaing + 30)
	cancel_button:SetText("Cancel")
	cancel_button.OnClick = gui.quick_start.Cancel
end

function gui.quick_start.Launch()
	if gui.map ~= nil then
		gs.switch("jeu/game", gui.map)
	end
end

function gui.quick_start.Cancel()
	gui.quick_start.panel:Remove()
	gui.main_menu.Load()
end

return gui
