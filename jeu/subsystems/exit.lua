-- exit component

local exit = {}

function exit.init_entity(self,cfg)
   self.x,self.y = cfg.x,cfg.y
   exit.exits[self] = true
end

function exit.release_entity(self)
   exit.exits[self] = nil
end

function exit.init_system()
   exit.exits = {}
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

function exit.random(role)
   return _table_random(exit.exits)
end

return exit
