-- SLAM test

local slam = require("libs/slam")
local state = {}

function state.enter()
   state.music = love.audio.newSource("assets/music.wav","stream")
   state.music:setLooping(true)
   state.music:setVolume(0.4)
   love.audio.play(state.music)

   state.effect = love.audio.newSource({"assets/pew.wav"},
      "static")
end

function state.keypressed()
   local instance = state.effect:play()
   instance:setPitch(.5 + math.random() * .5)
end

return state
