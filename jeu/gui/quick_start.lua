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
    gui.quick_start.multichoice.OnChoiceSelected = function()
      gui.quick_start.map = gui.quick_start.multichoice:GetChoice()
	end
   
   local files = love.filesystem.getDirectoryItems("assets/maps")
   for k, file in ipairs(files) do
      local the_file = "assets/maps/" .. file
      if love.filesystem.isFile(the_file) then
         local file_ext = string.sub(file, string.find(file, "[.]")+1)
         local file_name = string.sub(file, 1, string.find(file, "[.]")-1)
         if file_ext == "lua" then
            gui.quick_start.multichoice:AddChoice(file_name)
         end
      end
   end
   gui.quick_start.multichoice:SetChoice("sewers")
   gui.quick_start.map = "sewers"
   
   local multichoice = loveframes.Create("multichoice", frame)
   multichoice:SetSize(200, 30)
   multichoice:SetPos(width / 2 - 100, height / 2 - 15 - 2 * object_spaing - 60)
   multichoice:AddChoice("Hunter")
   multichoice:AddChoice("Ghost")
   multichoice.OnChoiceSelected = function()
      gui.quick_start.role = multichoice:GetChoice()
	end
   multichoice:SetChoice("Ghost")
   gui.quick_start.role = multichoice:GetChoice()

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
	if gui.quick_start.map ~= nil then
      love.audio.stop(audio.sounds.menu_music)
      audio.LoopMusic(audio.sounds.map_music2, 0.05)
      local map_file = "assets/maps/" .. gui.quick_start.map .. ".lua"
		gs.switch("jeu/game", map_file, {role = string.lower(gui.quick_start.role)})
	end
end

function gui.quick_start.Cancel()
   love.audio.play(audio.sounds.menu_click)
	gui.quick_start.panel:Remove()
	gui.main_menu.Load()
end

return gui
