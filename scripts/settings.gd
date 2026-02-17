extends Control

const CLICK_SFX := preload("res://assets/audio/click_sfx.mp3")

@onready var exit_button: Button = get_node_or_null("Menu/ExitButton") as Button
@onready var volume_slider: HSlider = get_node_or_null("Menu/VBox/VBoxVolume/HBoxVolume/HSlider") as HSlider
@onready var music_toggle: CheckButton = get_node_or_null("Menu/VBox/HBoxMusic/Music") as CheckButton
@onready var vibration_toggle: CheckButton = get_node_or_null("Menu/VBox/HBoxVibration/CheckButton") as CheckButton
@onready var click_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	click_player.stream = CLICK_SFX
	add_child(click_player)
	if exit_button and not exit_button.pressed.is_connected(_on_exit_button_pressed):
		exit_button.pressed.connect(_on_exit_button_pressed)
	if volume_slider:
		volume_slider.set_value_no_signal(Global.sfx_volume * 100.0)
		if not volume_slider.value_changed.is_connected(_on_volume_slider_value_changed):
			volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	if music_toggle:
		music_toggle.set_pressed_no_signal(Global.music_enabled)
		if not music_toggle.toggled.is_connected(_on_music_toggled):
			music_toggle.toggled.connect(_on_music_toggled)
	if vibration_toggle:
		vibration_toggle.set_pressed_no_signal(Global.vibration_enabled)
		if not vibration_toggle.toggled.is_connected(_on_vibration_toggled):
			vibration_toggle.toggled.connect(_on_vibration_toggled)

	AudioManager.set_sfx_volume(Global.sfx_volume)
	if Global.music_enabled:
		AudioManager.set_music_volume(Global.music_volume)
	else:
		AudioManager.set_music_volume(0.0)


func _on_exit_button_pressed() -> void:
	if click_player.playing:
		click_player.stop()
	click_player.play()
	var root := get_tree().current_scene
	if root and root.has_method("show_main_menu"):
		root.show_main_menu()


func _on_volume_slider_value_changed(value: float) -> void:
	Global.music_volume = clamp(value / 100.0, 0.0, 1.0)
	if Global.music_enabled:
		AudioManager.set_music_volume(Global.music_volume)


func _on_music_toggled(is_on: bool) -> void:
	if click_player.playing:
		click_player.stop()
	click_player.play()
	Global.music_enabled = is_on
	if is_on:
		AudioManager.set_music_volume(Global.music_volume)
	else:
		AudioManager.set_music_volume(0.0)


func _on_vibration_toggled(is_on: bool) -> void:
	if click_player.playing:
		click_player.stop()
	click_player.play()
	Global.vibration_enabled = is_on
