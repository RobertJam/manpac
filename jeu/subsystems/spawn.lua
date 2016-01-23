-- spawn component

local spawn = {}

function spawn.init_entity(self,cfg)
   self.x,self.y = cfg.x,cfg.y
   self.team = cfg.team
   if self.team == "hunter" then
      spawn.hunter_spawns[self] = true
   else
      spawn.ghost_spawns[self] = true
   end
   self.placeEntity = function (self,entity)
      print("Spawn placing entity at "..self.x..";"..self.y)
      entity:setPosition(self.x,self.y)
   end
end

function spawn.release_entity(self)
   if self.team == "hunter" then
      spawn.hunter_spawns[self] = nil
   else
      spawn.ghost_spawns[self] = nil
   end
end

function spawn.init_system()
   spawn.hunter_spawns = {}
   spawn.ghost_spawns = {}
end

local function _table_random(t)
   local keys, i = {}, 1
   for k,_ in pairs(t) do
      keys[i] = k
      i= i+1
   end
   local m = math.random(1,#keys)
   return keys[m]
end

function spawn.random(role)
   if role == "hunter" then
      return _table_random(spawn.hunter_spawns)
   else
      return _table_random(spawn.ghost_spawns)
   end
end

return spawn
