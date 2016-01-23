local hunter = {}

function hunter.init_entity(self)
   self.hello = function()
      print("HELLO HUNTER!!!")
   end
end

function hunter.init_system()
end

return hunter
