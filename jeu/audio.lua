local audio = {
   directory = "sons/",
   sounds = {
      fantome_approche = {file = "fantome_approche.wav", is_sfx = true },
      fantom_construit_barriere = {file = "fantom_construit_barriere.wav", is_sfx = true },
      victoire_fantome = {file = "victoire_fantome.wav", is_sfx = true },
      victoire_chasseurs = {file = "victoire_chasseurs.wav", is_sfx = true },
      chasseur_casse_barriere = {file = "chasseur_casse_barriere.wav", is_sfx = true },
      fantome_recupere_barriere = {file = "fantome_recupere_barriere.wav", is_sfx = true },
      chasseur_capture_fantome = {file = "chasseur_capture_fantome.wav", is_sfx = true },
      menu_click = {file = "menu_click.wav", is_sfx = true },
      menu_music = {file = "menu_music.wav", is_sfx = false },
      map_music1 = {file = "map_music1.wav", is_sfx = false },
      map_music2 = {file = "map_music2.wav", is_sfx = false }
   },
   slam = require("libs/slam")
}

function audio.SetSfxVolume(volume)
   audio.sfx_volume = volume
   print("sfx: " .. tostring(volume))
   for sound_name,sound_data in pairs(audio.sounds) do
      if audio.sounds[sound_name].is_sfx then
         audio.sounds[sound_name].source:setVolume(volume)
      end
   end
end

function audio.SetMusicVolume(volume)
   audio.music_volume = volume
   print("music: " .. tostring(volume))
   for sound_name,sound_data in pairs(audio.sounds) do
      if not audio.sounds[sound_name].is_sfx then
         audio.sounds[sound_name].source:setVolume(volume)
      end
   end
end

function audio.load()
   local gameplay_cfg = require("game_cfg")
   for sound_name,sound_data in pairs(audio.sounds) do
      audio.sounds[sound_name].source = love.audio.newSource(audio.directory .. sound_data.file, 'static')
      print(sound_name)
   end
   audio.SetSfxVolume(gameplay_cfg.game.sfx_volume)
   audio.SetMusicVolume(gameplay_cfg.game.music_volume)
end

function audio.LoopMusic(sound)
   sound.source:setLooping(true)
   love.audio.play(sound.source)
   audio.current_music = sound.source
end

return audio
