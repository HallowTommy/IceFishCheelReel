extends Label

@onready var bubble_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func show_text(text_value: String, color: Color) -> void:
	text = text_value
	self_modulate = color
	if bubble_sprite == null:
		bubble_sprite = get_node_or_null("AnimatedSprite2D")
	scale = Vector2.ONE * 0.6
	var bubble_delay := 0.0
	var bubble_start_delay := 0.5
	if bubble_sprite != null:
		bubble_sprite.visible = true
		bubble_sprite.stop()
		bubble_sprite.frame = 0
		bubble_delay = bubble_start_delay + _get_bubble_duration()
		if not bubble_sprite.animation_finished.is_connected(_on_bubble_animation_finished):
			bubble_sprite.animation_finished.connect(_on_bubble_animation_finished)
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 80.0, 0.6)
	tween.tween_property(self, "self_modulate:a", 0.0, 0.6)
	if bubble_sprite != null:
		_play_bubble_after_delay(bubble_start_delay)
	var scale_track := tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
	scale_track.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(queue_free)

func _get_bubble_duration() -> float:
	if bubble_sprite == null:
		return 0.0
	if bubble_sprite.sprite_frames == null:
		return 0.0
	var anim_name := "bubble"
	if not bubble_sprite.sprite_frames.has_animation(anim_name):
		return 0.0
	var frame_count := bubble_sprite.sprite_frames.get_frame_count(anim_name)
	var fps := bubble_sprite.sprite_frames.get_animation_speed(anim_name)
	var speed: float = fps * max(bubble_sprite.speed_scale, 0.001)
	if speed <= 0.0 or frame_count <= 0:
		return 0.0
	return float(frame_count) / speed

func _position_bubble() -> void:
	if bubble_sprite == null:
		return
	var label_size := size
	if label_size == Vector2.ZERO:
		return
	bubble_sprite.centered = true
	bubble_sprite.position = label_size * 0.5

func _play_bubble_after_delay(delay: float) -> void:
	if bubble_sprite == null:
		return
	if not is_inside_tree():
		await ready
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(delay).timeout
	if bubble_sprite != null:
		bubble_sprite.play("bubble")

func _on_bubble_animation_finished() -> void:
	if bubble_sprite != null:
		bubble_sprite.queue_free()
