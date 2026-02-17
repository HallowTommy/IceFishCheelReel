extends Node

const CLICK_SFX := preload("res://assets/audio/click_sfx.mp3")

@onready var main_menu: Control = $UI/MainMenu
@onready var rod_upgrade: Control = $UI/RodUpgrade
@onready var setting: Control = $UI/Setting
@onready var level_select: Control = $UI/LevelSelect
@onready var click_player: AudioStreamPlayer = AudioStreamPlayer.new()

var _click_sfx_enabled := false



func _ready() -> void:
	click_player.stream = CLICK_SFX
	add_child(click_player)
	call_deferred("_enable_click_sfx")
	if Global.show_level_select_on_main:
		Global.show_level_select_on_main = false
		_show_screen(level_select)


func _show_screen(screen: Control) -> void:
	main_menu.visible = false
	rod_upgrade.visible = false
	setting.visible = false
	level_select.visible = false
	screen.visible = true


func _play_click() -> void:
	if not _click_sfx_enabled:
		return
	if click_player.playing:
		click_player.stop()
	click_player.play()


func _enable_click_sfx() -> void:
	_click_sfx_enabled = true


func show_main_menu() -> void:
	_show_screen(main_menu)


func _on_play_button_pressed() -> void:
	_play_click()
	_show_screen(level_select)


func _on_upgrade_button_pressed() -> void:
	_play_click()
	_show_screen(rod_upgrade)


func _on_setting_button_pressed() -> void:
	_play_click()
	_show_screen(setting)


func _on_exit_button_pressed() -> void:
	_play_click()
	get_tree().quit()
