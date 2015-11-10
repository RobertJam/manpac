--[[
lol.lua, v0.3

--]]

local lol = {}

local function index(t, k)
    for i = #t.__lols, 1, -1 do
        local v = t.__lols[i][k]
        if v then return v end
    end
end

local function rawindex(t, k)
    for i = #t.__lols, 1, -1 do
        local v = rawget(t.__lols[i], k)
        if v then return v end
    end
end

local function deepcopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for key, value in next, orig, nil do
            if key == '__lols' then
                copy[key] = shallowcopy(value)
            else
                copy[key] = deepcopy(value)
            end
        end
        setmetatable(copy, getmetatable(orig))
    else
        copy = orig
    end
    return copy
end

local metamethods = 
    {'__add', '__call', '__concat'  , '__div'
    ,'__le' , '__lt'  , '__mod'     , '__mul'
    ,'__pow', '__sub' , '__tostring', '__unm'}

setmetatable(lol, lol)
lol.__index = index
lol.__lols = {}

function lol:clone(into)
    local t = into or {}
    t.__index = index
    setmetatable(t, t)
    for _, mname in ipairs(metamethods) do
        t[mname] = function(...)
            local method = rawindex(t, mname)
            if type(method) ~= 'function' then
                error(mname .. '() not implemented', 3)
            end
            assert(type(method) == 'function', mname .. '() not implemented')
            return method(...)
        end
    end
    t.__lols = {self}
    if rawget(self, 'init') then
        rawget(self, 'init')(t)
    end
    return t
end

function lol:copy(into)
    local copy = into or {}
    for key, value in next, self, nil do
        copy[key] = value
    end
    setmetatable(copy, copy)
    if rawget(self, 'init') then
        rawget(self, 'init')(copy)
    end
    return copy
end

function lol:deepcopy(into)
    local function assimilate(to, from)
        for i = #from, 1, -1 do
            local lol = from[i]
            for key, value in next, lol, nil do
                if key == '__lols' then
                    assimilate(to, value)
                elseif not to[key] then
                    to[key] = deepcopy(value)
                end
            end
        end
    end
    local copy = into or {}
    for key, value in next, self, nil do
        if key == '__lols' then
            assimilate(copy, value)
            copy[key] = shallowcopy(value)
        else
            copy[key] = deepcopy(value)
        end
    end
    setmetatable(copy, copy)
    if rawget(self, 'init') then
        rawget(self, 'init')(copy)
    end
    return copy
end

function lol:include(...)
    for _, v in ipairs({...}) do
        self.__lols[#self.__lols + 1] = v
    end
end

function lol:exclude(...)
    for _, v in ipairs({...}) do
        for i = 1, #self.__lols do
            if self.__lols[i] == v then
                table.remove(self.__lols, i)
                break
            end
        end
    end
end

function lol:includes(other)
    for i = #self.__lols, 1, -1 do
        if other == self.__lols[i] then
            return true
        end
        return self.__lols[i]:includes(other)
    end
    return false
end

function lol:excludes(other)
    return not self:includes(other)
end

function lol:__tostring()
    setmetatable(self, nil)
    local s = tostring(self)
    setmetatable(self, self)
    return s
end

return lol
