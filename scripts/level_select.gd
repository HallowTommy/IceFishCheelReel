extends Control

const GAME_SCENE_PATH := "res://scenes/game.tscn"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const CLICK_SFX := preload("res://assets/audio/click_sfx.mp3")

@onready var screen_transition: ScreenTransition = $ScreenTransition
@onready var menu: Control = $Menu
@onready var click_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _is_transitioning := false


func _ready() -> void:
	click_player.stream = CLICK_SFX
	add_child(click_player)
	await screen_transition.clear(0.35)


func _play_click() -> void:
	if click_player.playing:
		click_player.stop()
	click_player.play()


func _on_play_level_1_pressed() -> void:
	_play_click()
	if _is_transitioning:
		return
	_is_transitioning = true
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(menu, "scale", Vector2(0.98, 0.98), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(menu, "modulate:a", 0.7, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if screen_transition:
		tween.parallel().tween_property(screen_transition._color_rect, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.tween_callback(Callable(self, "_go_to_game"))


func _go_to_game() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_exit_button_pressed() -> void:
	_play_click()
	var root := get_tree().current_scene
	if root and root.has_method("show_main_menu"):
		root.show_main_menu()
	else:
		get_tree().change_scene_to_file(MAIN_SCENE_PATH)
