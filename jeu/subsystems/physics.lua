-- physics subsystem

local physics = {world = nil} -- physics package

-- subsystem initialisation
function physics.init_system()
   love.physics.setMeter(32) -- box2D meter in pixels
   physics.world = love.physics.newWorld(0,0) -- horizontal,vertical gravity
   -- register box2d custom callbacks for sensors
   physics.world:setCallbacks(physics.begin_contact,physics.end_contact)
end

-- subsystem cleanup
function physics.release_system()
end

-- Box2D callbacks
function physics.begin_contact(a,b,coll)
   local entity_a = a:getUserData()
   local entity_b = b:getUserData()
end
function physics.end_contact(a,b,coll)
end

-- entity initialisation
function physics.init_entity(self, cfg)
   self.body = love.physics.newBody(physics.world, self.x/2,self.y/2, cfg.body_type or "dynamic")
   self.body:setLinearDamping(30)
   self.body:setFixedRotation(true)
   self.shape = nil
   if cfg.vertices then
      self.shape = love.physics.newChainShape(cfg.vertices,true)
   else
      self.shape = love.physics.newRectangleShape(47, 32,27, 32)
   end
   self.fixture = love.physics.newFixture(self.body, self.shape)
   self.fixture:setRestitution(3)
   self.fixture:setUserData(self)
   self.fixture:getMask( )
   self.fixture:setSensor(cfg.sensor or false)
   self.forceX = 0
   self.forceY = 0
   -- add setForces() method
   self.setForces = function(self,fx,fy)
      self.forceX = fx
      self.forceY = fy
   end
   self.setPosition = function(self,x,y)
      self.body:setPosition(x,y)
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
