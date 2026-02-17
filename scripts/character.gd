extends Node2D

var is_fishing = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var blink_timer = $BlinkTimer

func _ready():
	anim.play(_get_anim_name("idle"))
	_start_blink_timer()

func start_fishing():
	is_fishing = true

func stop_fishing():
	is_fishing = false
	anim.speed_scale = 1
	anim.play(_get_anim_name("idle"))

func _get_anim_name(base: String) -> String:
	var level := clampi(Global.rod_level, 1, 3)
	return "%s_level%d" % [base, level]

func _start_blink_timer():
	blink_timer.stop()
	blink_timer.wait_time = randf_range(2.0, 5.0)
	blink_timer.start()

func _on_blink_timer_timeout() -> void:
	if is_fishing:
		_start_blink_timer()
		return
	
	anim.play(_get_anim_name("blink"))
	
	if anim.animation_finished.is_connected(_on_blink_finished):
		anim.animation_finished.disconnect(_on_blink_finished)
	
	anim.animation_finished.connect(_on_blink_finished, CONNECT_ONE_SHOT)


func _on_blink_finished():
	if anim.animation == _get_anim_name("blink") and not is_fishing:
		anim.play(_get_anim_name("idle"))
		_start_blink_timer()

func force_idle_after_fishing():
	is_fishing = false
	anim.speed_scale = 1
	anim.stop()
	anim.play(_get_anim_name("idle"))
	_start_blink_timer()
