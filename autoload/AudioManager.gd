extends Node

var music_volume := 0.8
var sfx_volume := 0.8

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	var music = get_tree().current_scene
	if music and music.has_node("Music"):
		var player := music.get_node("Music") as AudioStreamPlayer2D
		if player:
			player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

func play_sfx(stream: AudioStream):
	var root := get_tree().current_scene
	if not root:
		return
	var player := AudioStreamPlayer.new()
	player.bus = &"SFX"
	player.stream = stream
	root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
