-- input player controler
-- maps keyboard input to character controls

local input = {}

function input.init_entity(self,cfg)
   self.keymap = cfg.keymap or {move_left = "left",
                                move_right = "right",
                                move_up = "up",
                                move_down = "down"}
end

function input.update(entities)
   for _,entity in pairs(entities) do
      for action,key in pairs(entity.keymap) do
         if love.keyboard.isDown(key) then
            systems.character[action](entity)
         end
      end
   end
end

return input
