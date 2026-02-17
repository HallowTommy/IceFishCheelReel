extends Control

const CLICK_SFX := preload("res://assets/audio/click_sfx.mp3")
const ROD_BG_BY_LEVEL := {
	1: preload("res://assets/art/background/background_level1.png"),
	2: preload("res://assets/art/background/background_level2.png"),
	3: preload("res://assets/art/background/background_level3.png")
}
const ROD_IMAGE_BY_LEVEL := {
	1: preload("res://assets/art/rod/rod_level1.png"),
	2: preload("res://assets/art/rod/rod_level2.png"),
	3: preload("res://assets/art/rod/rod_level3.png")
}

@onready var level: Label = $Menu/Rod/Level
@onready var rod_background: TextureRect = $Menu/Rod
@onready var rod_image: TextureRect = $Menu/Rod/RodImage
@onready var cost: Label = $Menu/UpgradeButton/Cost/Cost
@onready var blue_chance_bar: ProgressBar = $Menu/LevelCost/FishBox/BlueFish/VBoxContainer/FishChanceBar
@onready var orange_chance_bar: ProgressBar = $Menu/LevelCost/FishBox/OrangeFish/VBoxContainer/FishChanceBar
@onready var red_chance_bar: ProgressBar = $Menu/LevelCost/FishBox/RedFish/VBoxContainer/FishChanceBar
@onready var coin: Label = $Menu/CoinBackground/Coin/CoinLabel
@onready var click_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	click_player.stream = CLICK_SFX
	add_child(click_player)
	_update_ui()


func _play_click() -> void:
	if click_player.playing:
		click_player.stop()
	click_player.play()

func _get_upgrade_cost() -> int:
	return 100 + Global.rod_level * 50

func _update_ui() -> void:
	level.text = "Rod Level: " + str(Global.rod_level)
	var level_index := clampi(Global.rod_level, 1, 3)
	rod_background.texture = ROD_BG_BY_LEVEL.get(level_index, ROD_BG_BY_LEVEL[3])
	rod_image.texture = ROD_IMAGE_BY_LEVEL.get(level_index, ROD_IMAGE_BY_LEVEL[3])
	cost.text = "Cost: " + str(_get_upgrade_cost())
	coin.text = str(Global.currency)
	var c := Global.get_fish_chances()
	blue_chance_bar.value = clamp(int(c["blue"] * 100.0), 0, 100)
	orange_chance_bar.value = clamp(int(c["orange"] * 100.0), 0, 100)
	red_chance_bar.value = clamp(int(c["red"] * 100.0), 0, 100)

func _on_upgrade_button_pressed() -> void:
	_play_click()
	var cost_count := _get_upgrade_cost()
	if Global.currency >= cost_count:
		Global.currency -= cost_count
		Global.rod_level += 1
		_update_ui()


func _on_exit_button_pressed() -> void:
	_play_click()
	var root := get_tree().current_scene
	if root and root.has_method("show_main_menu"):
		root.show_main_menu()
