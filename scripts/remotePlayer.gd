extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var last_position := Vector2.ZERO
var last_direction := "down"

func _process(delta):
	# Smooth movement (optional)
		var lerp_speed := 25
		position.x = lerp(position.x, last_position.x, lerp_speed * delta)
		position.y = lerp(position.y, last_position.y, lerp_speed * delta)

func set_target_position(target: Vector2):
	last_position = target
	_update_animation_direction(target)

func _update_animation_direction(target: Vector2):
	var delta_pos = target - position
	var dir = delta_pos.normalized()

	if dir == Vector2.ZERO:
		animated_sprite.play("idle")
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.play("walk_right")
			last_direction = "right"
		else:
			animated_sprite.play("walk_left")
			last_direction = "left"
	else:
		if dir.y > 0:
			animated_sprite.play("walk_down")
			last_direction = "down"
		else:
			animated_sprite.play("walk_up")
			last_direction = "up"
