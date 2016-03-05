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

function utils.find_closest_barrier(self)
   -- FIXME: consider character direction instead of just the distance
   -- FIXME: consider a maximum distance
   local barrier_list = systems.barrier:getEntities()
   local min_dist = 100
   local selected = nil
   for i=1,#barrier_list do
      local dist = utils.dist(self,barrier_list[i])
      if dist < min_dist then
         min_dist = dist
         selected = barrier_list[i]
      end
   end
   return selected
end

function utils.barrier_position(self)
   return {x = math.floor((self.x + self.direction.x * (self.shape_width / 2)) / 64)
              * 64 +self.direction.x * 64 + 32,
           y = math.floor((self.y + self.direction.y * (self.shape_height / 2)) / 64)
              * 64 + self.direction.y * 64 + 32}
end

return utils
