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
	
	gui.quick_start.multichoice = loveframes.Create("multichoice", frame)
    gui.quick_start.multichoice:SetSize(200, 30)
    gui.quick_start.multichoice:SetPos(width / 2 - 100, height / 2 - 15 - object_spaing - 30)
    gui.quick_start.multichoice:AddChoice("sewers")
    gui.quick_start.multichoice:AddChoice("map_V4")
    gui.quick_start.multichoice:AddChoice("map_V5")
    gui.quick_start.multichoice:AddChoice("giant_rock_maze")
    gui.quick_start.multichoice:AddChoice("giant_earth_maze")
    gui.quick_start.multichoice.OnChoiceSelected = function()
    gui.map = "assets/maps/" .. gui.quick_start.multichoice:GetChoice() .. ".lua"
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
   love.audio.play(audio.sounds.menu_click)
	if gui.map ~= nil then
      love.audio.stop(audio.sounds.menu_music)
      
      local map_choice = gui.quick_start.multichoice:GetChoice()
      if map_choice == "sewers" then
         audio.LoopMusic(audio.sounds.map_music2, 0.05)
      elseif map_choice == "map_V4" then
         audio.LoopMusic(audio.sounds.map_music1, 0.05)
	  elseif map_choice == "map_V5" then
         audio.LoopMusic(audio.sounds.map_music1, 0.05)
	  elseif map_choice == "giant_rock_maze" then
         audio.LoopMusic(audio.sounds.map_music2, 0.05)
	  elseif map_choice == "giant_earth_maze" then
         audio.LoopMusic(audio.sounds.map_music1, 0.05) 
      else
         audio.LoopMusic(audio.sounds.map_music2, 0.05)
      end
      
		gs.switch("jeu/game", gui.map)
	end
end

function gui.quick_start.Cancel()
   love.audio.play(audio.sounds.menu_click)
	gui.quick_start.panel:Remove()
	gui.main_menu.Load()
end

return gui
