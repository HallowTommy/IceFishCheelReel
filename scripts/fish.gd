extends Node2D

var reward := 0
var fish_type := "blue"
@export var reward_sound: AudioStream

func _ready():
	match fish_type:
		"blue": $Sprite2D.texture = preload("res://assets/art/fish/blue.png")
		"orange": $Sprite2D.texture = preload("res://assets/art/fish/orange.png")
		"red": $Sprite2D.texture = preload("res://assets/art/fish/red.png")

func start_moving():
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 500, 1.5).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_on_reach_top)

func _on_reach_top():
	# Defer reward to next frame (after queue_free())
	var scene := get_tree().current_scene
	if scene != null and is_instance_valid(scene):
		scene.call_deferred("_apply_fish_reward", reward, fish_type, global_position)
	queue_free()
	if reward_sound:
		AudioManager.call_deferred("play_sfx", reward_sound)

func _get_color() -> Color:
	match fish_type:
		"blue": return Color.SKY_BLUE
		"orange": return Color.ORANGE
		"red": return Color.RED
		_: return Color.WHITE
