-- input player controler

local input = {}

function input.init_entity(self,keymap)
   self.keymap = keymap or {left = "left",
                            right = "right",
                            up = "up",
                            down = "down"}
   self.actions = {}
   self.clearActions = function(self)
      self.actions = {}
   end
end

function input.update()
   for action,key in pairs(self.keymap) do
      if love.keyboard.isDown(key) then
         table.insert(self.actions,action)
      end
   end
end

return input
