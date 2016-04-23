local audio = {
   global_volume = .05,
   directory = "sons/",
   sounds = {
      fantome_approche = "fantome_approche.wav",
      fantom_construit_barriere = "fantom_construit_barriere.wav",
      victoire_fantome = "victoire_fantome.wav",
      victoire_chasseurs = "victoire_chasseurs.wav",
      chasseur_casse_barriere = "chasseur_casse_barriere.wav",
      fantome_recupere_barriere = "fantome_recupere_barriere.wav",
      chasseur_capture_fantome = "chasseur_capture_fantome.wav",
      menu_click = "menu_click.wav",
      menu_music = "menu_music.wav",
      map_music1 = "map_music1.wav",
      map_music2 = "map_music2.wav"
   },
   slam = require("libs/slam")
}

-- love.audio.play(audio.sounds.menu_click)

function audio.load()
   for sound_name,sound_file in pairs(audio.sounds) do
      audio.sounds[sound_name] = love.audio.newSource(audio.directory .. sound_file, 'static')
   end
end

function audio.LoopMusic(music, volume)
   if not volume then volume = audio.global_volume end
   music:setLooping(true)
   music:setVolume(volume)
   love.audio.play(music)
   audio.current_music = music
end

return audio
