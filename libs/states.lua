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

function states.mousepressed(x, y, button)
	if states.current and states.current.mousepressed then
      states.current.mousepressed(x, y, button)
   end
end

function states.mousereleased(x, y, button)
	if states.current and states.current.mousereleased then
      states.current.mousereleased(x, y, button)
   end
end

function states.keypressed(key, isrepeat)
	if states.current and states.current.keypressed then
      states.current.keypressed(key, isrepeat)
   end
end

function states.keyreleased(key)
	if states.current and states.current.keyreleased then
      states.current.keyreleased(key)
   end
end

function states.textinput(text)
	if states.current and states.current.textinput then
      states.current.textinput(text)
   end
end

return states
