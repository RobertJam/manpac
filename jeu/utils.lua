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

function utils.angle(v1,v2)
   local x1,y1,z1 = utils.normalize(v1.x,v1.y)
   local x2,y2,z2 = utils.normalize(v2.x,v2.y)
   local cross = x1*y2-x2*y1
   local dot = x1*x2+y1*y2
   return math.atan2(cross,dot)
end

function utils.dir(a,b)
   local x,y,z = utils.normalize(b.x - a.x,b.y - a.y)
   return {x = x,y = y}
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
   return {x = math.floor((self.x + self.direction.x ) / 64)
              * 64 +self.direction.x * 64 + 32,
           y = math.floor((self.y - self.direction.y ) / 64)
              * 64 - self.direction.y * 64 + 32}
end

function utils.tprint ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

return utils
