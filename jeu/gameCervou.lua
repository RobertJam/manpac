-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

local state = {}
local vt = 10
perso = { x = 50, y = 50, speed = 30, radius = 10, segments=100}
mur = { x =30, y = 500, width = 100, height= 20}
function state.enter()
end

function state.update(dt)


    if perso.x <= 0 then 
    	if love.keyboard.isDown("q") then vt = 0 else
    		vt = 10
    	end
    elseif perso.x + perso.radius >= 0 + love.window.getWidth( )then 
    	if love.keyboard.isDown("d") then vt = 0 else
    		vt = 10
    	end
    elseif perso.y <= 0 then 
    	if love.keyboard.isDown("z") then vt = 0 
    	else
    		vt = 10
    	end
    elseif perso.y + perso.radius >= 0 + love.window.getHeight( )then 
    	if love.keyboard.isDown("s") then vt = 0 
    	else
    		vt = 10
    	end
    end

	-- We will decrease the variable by 1/s if any of the wasd keys is pressed. 
    if love.keyboard.isDown("z") then perso.y = perso.y - vt end
    if love.keyboard.isDown("s") then perso.y = perso.y + vt end
    if love.keyboard.isDown("q") then perso.x = perso.x - vt end
    if love.keyboard.isDown("d") then perso.x = perso.x + vt end

    if CheckCollision(perso.x, perso.y, perso.radius, perso.radius, mur.x, mur.y, mur.width, mur.height) then
		vt = 0
	end
end

function state.draw()
	love.graphics.circle("fill", perso.x, perso.y, perso.speed, perso.segments) -- Draw white circle with 100 segments.
	love.graphics.rectangle( "fill", mur.x, mur.y,mur. width, mur.height )
end

<<<<<<< HEAD
function state.mousepressed(x, y, button)
end

function state.mousereleased(x, y, button)
end

function state.keypressed(key, isrepeat)
end

function state.keyreleased(key)
end

function state.textinput(text)
end

return state
=======
return state
>>>>>>> 3a1b1d65900b3159812a9f22860fa9f9e9d11fdb
