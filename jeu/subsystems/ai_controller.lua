-- ai player controler

local ai = {}

function ai.init_entity(self,keymap)
   -- TODO: init ai controller data
end

function ai.update(entities,dt)
   for _,entity in pairs(entities) do
      local x_bot, y_bot = 0, 0
      local deplacement_bot = 1000
      x_bot = love.math.random(-deplacement_bot, deplacement_bot)
      y_bot = love.math.random(-deplacement_bot, deplacement_bot)
      game.bot:setForces(x_bot,y_bot)
   end
end

return ai
