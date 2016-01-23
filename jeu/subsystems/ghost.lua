local ghost = {}

function ghost.init_entity(self,cfg)
   self.nbarriers = cfg.max_barriers or 3
end

function ghost.init_system()
end

function ghost.create_barrier(self)
   if self.nbarriers == 0 then return end
   self.nbarriers = self.nbarriers - 1
end

return ghost
