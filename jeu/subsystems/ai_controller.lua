-- ai player controler

local ai = {}

function ai.init_entity(self,cfg)
   self.behavior = cfg.behavior or "stalker"
   self.target = cfg.target or game.player
end

function ai.update(entities,dt)
   for _,entity in pairs(entities) do
      if entity.behavior == "stupid" then
         local x_bot, y_bot = 0, 0
         local deplacement_bot = 1000
         x_bot = love.math.random(-deplacement_bot, deplacement_bot)
         y_bot = love.math.random(-deplacement_bot, deplacement_bot)
         entity:setForces(x_bot,y_bot)
      elseif entity.behavior == "stalker" then
         entity:setForces(entity.target.x,entity.target.y)
      end
   end
end

return ai
