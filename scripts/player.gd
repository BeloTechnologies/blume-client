extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var max_speed = 150
var acceleration = 1000
var friction = 600

var input_direction = Vector2.ZERO
var last_direction = "down"

func _physics_process(delta):
	input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	if input_direction != Vector2.ZERO:
		# Accelerate toward the input direction
		velocity = velocity.move_toward(input_direction * max_speed, acceleration * delta)
		
		# Directional animations
		if abs(input_direction.x) > abs(input_direction.y):
			if input_direction.x > 0:
				animated_sprite.play("walk_right")
				last_direction = "right"
			else:
				animated_sprite.play("walk_left")
				last_direction = "left"
		else:
			if input_direction.y > 0:
				animated_sprite.play("walk_down")
				last_direction = "down"
			else:
				animated_sprite.play("walk_up")
				last_direction = "up"
	else:
		# Apply friction (slows the character down when not moving)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		animated_sprite.play("idle")

	# Move the character using updated velocity
	move_and_slide()
