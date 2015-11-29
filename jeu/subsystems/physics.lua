-- physics subsystem

local physics = {world = nil} -- physics package

-- subsystem initialisation
function physics.init_system()
   love.physics.setMeter(32) -- box2D meter in pixels
   physics.world = love.physics.newWorld(0,0) -- horizontal,vertical gravity
end

-- subsystem cleanup
function physics.release_system()
end

-- entity initialisation
function physics.init_entity(self)
   -- physics related data
   -- this may depend on other subsystems (requires (x;y) coordinates from base entity
   self.body = nil
   self.shape = nil
   self.fixture = nil
   self.body = love.physics.newBody(physics.world, self.x/2,self.y/2, "dynamic")
   self.body:setLinearDamping(10)
   self.body:setFixedRotation(true)
   self.shape = love.physics.newRectangleShape(27, 32)
   self.fixture = love.physics.newFixture(self.body, self.shape)
   self.forceX = 0
   self.forceY = 0
   -- add setForces() method
   self.setForces = function(self,fx,fy)
      self.forceX = fx
      self.forceY = fy
   end
end

function physics.update(entities,dt)
   -- box2d update
   physics.world:update(dt)
   -- update all entities, assumes they're all physic entities
   for _,entity in pairs(entities) do
      entity.body:applyForce(entity.forceX,entity.forceY)
      entity.x,entity.y = entity.body:getWorldCenter()
   end
end

return physics
