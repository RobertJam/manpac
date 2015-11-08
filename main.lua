
game = {time=0}

-- update a frame
function love.update(dt)
   game.time = game.time + dt
end

-- draw a frame
function love.draw()
   love.graphics.print("Hello les gens...le temps passe...",100,100)
   love.graphics.print(game.time,100,115)
end
