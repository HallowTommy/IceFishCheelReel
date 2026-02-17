extends Node2D

@onready var rope: Line2D = $Line2D
@onready var hook: Sprite2D = $Hook
@onready var hook_cordinate: AnimationPlayer = $"../AnimationPlayer"

@export var fish_scene: PackedScene

var is_moving := false


# Adjust these based on your scene layout
@export var up_pos := Vector2(0, 0)
@export var down_pos := Vector2(0, 1000)

var caught_fish = null

func _ready():
	hook_cordinate.speed_scale = 1
	hook_cordinate.play("idle_hook")
	_update_rope()

func _process(delta):
	_update_rope()

func drop_and_catch():
	if is_moving:
		return
	is_moving = true
	
	get_tree().current_scene.get_node("Character").start_fishing()

	_move_down()

func _move_down():
	var anim = get_tree().current_scene.get_node("Character/AnimatedSprite2D")
	anim.speed_scale = 1
	anim.play(_get_anim_name("fishing_toggle"))
	
	hook_cordinate.speed_scale = 1
	hook_cordinate.play("hook_coordinate")

	var t := create_tween()
	t.tween_property(hook, "position", down_pos, 1.5)
	t.finished.connect(_on_reach_bottom)

func _on_reach_bottom():
	_spawn_fish()
	_move_up()

func _move_up():
	var anim = get_tree().current_scene.get_node("Character/AnimatedSprite2D")
	var anim_name := _get_anim_name("fishing_toggle")
	anim.frame = anim.sprite_frames.get_frame_count(anim_name) - 1
	anim.speed_scale = -1
	anim.play(anim_name)
	
	hook_cordinate.play("hook_coordinate_reverse")
	
	var t := create_tween()
	t.tween_property(hook, "position", up_pos, 1.5)
	t.finished.connect(_on_reach_top)

func _on_reach_top():
	#var anim = get_tree().current_scene.get_node("Character/AnimatedSprite2D")
	#anim.stop()
	#get_tree().current_scene.get_node("Character").stop_fishing()
	var character = get_tree().current_scene.get_node("Character")
	character.force_idle_after_fishing()
	
	hook_cordinate.speed_scale = 1
	hook_cordinate.play("idle_hook")
	
	if caught_fish:
		caught_fish.start_moving()
		caught_fish = null
	is_moving = false

func _update_rope():
	rope.points = [Vector2.ZERO, hook.position]

func _get_anim_name(base: String) -> String:
	var level := clampi(Global.rod_level, 1, 3)
	return "%s_level%d" % [base, level]

func _spawn_fish():
	var game = get_tree().current_scene
	var fish_type = game._roll_fish()
	var reward = game._get_reward(fish_type)

	var fish = fish_scene.instantiate()
	fish.position = hook.global_position

	# IMPORTANT: set reward BEFORE attaching to hook
	fish.fish_type = fish_type
	fish.reward = reward

	get_tree().current_scene.add_child(fish)

	# Attach fish to hook while going up
	fish.get_parent().remove_child(fish)
	hook.add_child(fish)
	fish.position = Vector2.ZERO

	caught_fish = fish
