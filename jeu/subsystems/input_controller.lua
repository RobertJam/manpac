-- input player controler
-- maps keyboard input to character controls


local input = {}


function input.init_entity(self,cfg)
   self.keymap = cfg.keymap or {}
end

function input.update(entities)
   for _,entity in pairs(entities) do
      for action,key in pairs(entity.keymap) do
         if love.keyboard.isDown(key) then
            entity[action](entity)
         end
      end
      if entity.move_x == 0 and entity.move_y == 0 then
         entity["dont_move"](entity)
      end
   end
end

return input
