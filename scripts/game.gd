extends Node

@export var floating_text_scene: PackedScene
@export var fish_scene: PackedScene

@onready var fish_spawn_point: Marker2D = $FishSpawnPoint
@onready var coin_label: Label = $CanvasLayer/UI/CoinBackground/Coin/CoinLabel
@onready var coin_icon: TextureRect = $CanvasLayer/UI/CoinBackground/Coin/CoinIcon
@onready var tap_button: Button = $CanvasLayer/UI/TapButton
@onready var back_button: Button = $CanvasLayer/UI/BackButton
@onready var screen_transition: ScreenTransition = $ScreenTransition

var _is_transitioning := false

const COIN_TEXTURE := preload("res://assets/art/coin.png")

const MAIN_SCENE_PATH := "res://scenes/main.tscn"

func _ready() -> void:
	if coin_label:
		coin_label.text = str(Global.currency)
	await screen_transition.clear(0.6)

func _on_tap() -> void:
	var fish_type := _roll_fish()
	var reward := _get_reward(fish_type)
	
	tap_button.disabled = true
	back_button.disabled = true
	$RopeRig.drop_and_catch()

func _roll_fish() -> String:
	var chances := Global.get_fish_chances()
	var r := randf()
	if r < chances["blue"]:
		return "blue"
	elif r < chances["blue"] + chances["orange"]:
		return "orange"
	else:
		return "red"

func _get_reward(fish_type: String) -> int:
	match fish_type:
		"blue":
			return 25
		"orange":
			return 50
		"red":
			return 75
		_:
			return 0

func _spawn_floating_text(text_value: String, fish_type: String) -> void:
	var ft := floating_text_scene.instantiate() as Label
	ft.position = fish_spawn_point.global_position
	var color := Color.WHITE
	match fish_type:
		"blue":
			color = Color.SKY_BLUE
		"orange":
			color = Color.ORANGE
		"red":
			color = Color.RED
	ft.show_text(text_value, color)
	get_tree().current_scene.add_child(ft)

func _apply_fish_reward(reward_value: int, fish_type_value: String, world_position: Vector2) -> void:
	Global.currency += reward_value

	var ft := floating_text_scene.instantiate() as Label
	ft.position = world_position
	var color := Color.WHITE
	match fish_type_value:
		"blue":
			color = Color.SKY_BLUE
		"orange":
			color = Color.ORANGE
		"red":
			color = Color.RED
	ft.show_text("+" + str(reward_value), color)
	add_child(ft)

	_spawn_coin_fx(reward_value, world_position)

	coin_label.text = str(Global.currency)
	tap_button.disabled = false
	back_button.disabled = false

func _spawn_coin_fx(reward_value: int, world_position: Vector2) -> void:
	var coin_count: int = 1
	match reward_value:
		25:
			coin_count = 8
		50:
			coin_count = 15
		75:
			coin_count = 30
	var start_pos: Vector2 = get_viewport().get_canvas_transform() * world_position
	var target_pos := coin_icon.global_position + coin_icon.size * 0.5

	for i in range(coin_count):
		var coin := TextureRect.new()
		coin.texture = COIN_TEXTURE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coin.custom_minimum_size = Vector2(36, 36)
		coin.pivot_offset = coin.custom_minimum_size * 0.5
		coin.global_position = start_pos + Vector2(randf_range(-20, 20), randf_range(-20, 20)) - coin.pivot_offset
		$CanvasLayer.add_child(coin)

		var duration := 0.6 + randf() * 0.2
		var tween := create_tween()
		tween.tween_property(coin, "global_position", target_pos - coin.pivot_offset, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(coin, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(coin, "scale", Vector2.ONE * 0.7, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.finished.connect(coin.queue_free)


func _on_button_pressed() -> void:
	_on_tap()
	coin_label.text = str(Global.currency)

func _on_back_button_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	tap_button.disabled = true
	back_button.disabled = true
	await screen_transition.cover(0.5)
	_go_to_level_select()


func _go_to_level_select() -> void:
	Global.show_level_select_on_main = true
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
