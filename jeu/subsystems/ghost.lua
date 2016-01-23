local ghost = {}

function ghost.init_entity(self)
   self.hello = function()
      print("HELLO GHOST!!!")
   end
end

function ghost.init_system()
end

return ghost
