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
      if not entity:isMoving() then
         entity:setDirection(entity.direction)
      end
   end
end

return input
