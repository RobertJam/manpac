-- gamestate management

states = {current = nil}

function states.switch(name,...)
   if states.current and states.current.leave then
      states.current.leave()
   end
   -- -- invalidate already loaded package
   -- package.loaded[name] = false
   print("Loading state "..name)
   state = require(name)
   print(state)
   states.current = state
   if state.enter then
      state.enter(...)
   end
end

function states.update(dt)
   if states.current and states.current.update then
      states.current.update(dt)
   end
end

function states.draw()
   if states.current and states.current.draw then
      states.current.draw()
   end
end

return states
