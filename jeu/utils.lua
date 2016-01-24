local utils = {}


function utils.rand_range(min,max)
   return love.math.random()*(max-min)+min
end

function utils.normalize(x,y)
   local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end
end

function utils.dist(a,b)
   return ((b.x-a.x)^2+(b.y-a.y)^2)^0.5
end

return utils
