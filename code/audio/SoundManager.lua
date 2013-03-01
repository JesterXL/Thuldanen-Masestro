

SoundManager = {}
SoundManager.inst = nil

function SoundManager:new()

	local manager = {}
	manager.notesVolume = 1
	manager.effectsVolume = 1 -- 0.3
	manager.musicVolume = 1

	manager.CHANNEL_NOTES = 1
	manager.MUSIC_CHANNEL = 2
	manager.CHANNEL_EFFECTS = 3

	manager.gravityCSound = nil
	manager.gravityDSound = nil
	manager.gravityESound = nil
	manager.gravityFSound = nil
	manager.gravityGSound = nil
	manager.gravityASound = nil
	manager.gravityBSound = nil
	manager.gravityCHIGHSound = nil
	manager.levelEndMusic = nil
	
	function manager:init()
		self:reserveChannels()
		self:loadSoundEffects()
	end

	function manager:reserveChannels()
		local result, err = audio.reserveChannels(5)
		assert(result == 5, "SoundManager::reserve Channels, failed to reserve all 5 channels.", err)
	end

	function manager:adjustVolume()
		audio.setVolume(self.masterVolume)
		audio.setVolume(self.musicVolume, {channel=self.CHANNEL_MUSIC})
		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_DIALOGUE})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_EFFECTS})

		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_STATIC_START})
		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_STATIC_END})
	end

	function manager:loadSoundEffects()
		self.gravityCSound = audio.loadSound("audio/notes/gravity/gravity-c.mp3")
		self.gravityDSound = audio.loadSound("audio/notes/gravity/gravity-d.mp3")
		self.gravityESound = audio.loadSound("audio/notes/gravity/gravity-e.mp3")
		self.gravityFSound = audio.loadSound("audio/notes/gravity/gravity-f.mp3")
		self.gravityGSound = audio.loadSound("audio/notes/gravity/gravity-g.mp3")
		self.gravityASound = audio.loadSound("audio/notes/gravity/gravity-a.mp3")
		self.gravityBSound = audio.loadSound("audio/notes/gravity/gravity-b.mp3")
		self.gravityCHIGHSound = audio.loadSound("audio/notes/gravity/gravity-c-high.mp3")
		self.levelEndMusic = audio.loadSound("audio/level-end.wav")
	end

	function manager:playEffectSound(soundFile)
		local channel = audio.play(soundFile)
		audio.setVolume(self.effectsVolume, {channel=channel})
	end

	function manager:playNoteSound(soundFile)
		audio.stop(self.CHANNEL_NOTES)
		audio.play(soundFile, {channel=self.CHANNEL_NOTES})
		audio.setVolume(self.notesVolume, {channel=self.CHANNEL_NOTES})
	end

	function manager:playGravityNote(note)
		local name = "gravity" .. string.upper(note) .. "Sound"
		local handle = self[name];
		self:playNoteSound(handle)
	end

	function manager:playLevelEndMusic()
		audio.stop(self.CHANNEL_MUSIC)
		audio.play(self.levelEndMusic, {channel=self.CHANNEL_MUSIC})
		audio.setVolume(self.musicVolume, {channel=self.CHANNEL_MUSIC})
	end

	return manager

end

if SoundManager.inst == nil then
	SoundManager.inst = SoundManager:new()
	SoundManager.inst:init()
end

return SoundManager