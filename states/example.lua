-- splashscreen state

local state = {}

function state.enter()
end

function state.leave()
end

function state.update(dt)
end

function state.draw()
   love.graphics.print("On est dans un nouveau state, F1 pour revenir au main",100,100)
end

return state
