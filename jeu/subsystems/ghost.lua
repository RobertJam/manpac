local ghost = {}

function ghost.init_entity(self)
end

function ghost.init_system()
end

function ghost.enter_collision(self,other)
   print("Ghost colliding")
end

return ghost
