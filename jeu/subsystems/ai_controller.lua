-- ai player controler

local ai = {}

function ai.init_entity(self)
   self.behavior = "stalker"
   self.target = nil
end

function ai.update(entities,dt)
   for _,entity in pairs(entities) do
      if entity.behavior == "stupid" then
         local x_bot, y_bot = 0, 0
         local deplacement_bot = 1000
         x_bot = love.math.random(-deplacement_bot, deplacement_bot)
         y_bot = love.math.random(-deplacement_bot, deplacement_bot)
         game.bot:setForces(x_bot,y_bot)
      elseif entity.behavior == "stalker" then
         game.stalker:setForces(entity.target.x,entity.target.y)
      end
   end
end

return ai
