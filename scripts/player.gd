extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var max_speed = 150
var acceleration = 1000
var friction = 600

var input_direction = Vector2.ZERO
var last_direction = "down"

# Multiplayer networking
var last_sent_position := Vector2.ZERO
var send_timer := 0.0
var send_interval := 0.05  # Send ~20 times/sec
var has_sent_initial_position := false

func _physics_process(delta):
	input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * max_speed, acceleration * delta)

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
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		animated_sprite.play("idle")

	move_and_slide()

	# Initial position broadcast after connection
	if not has_sent_initial_position:
		var main = get_parent()
		if main.connected and main.player_id != "":
			_send_position()
			has_sent_initial_position = true

	# Regular periodic updates if moved
	send_timer += delta
	if send_timer >= send_interval and position.distance_to(last_sent_position) > 1:
		_send_position()
		last_sent_position = position
		send_timer = 0.0

func _send_position():
	var main = get_parent()
	if not main.connected or main.player_id == "":
		return

	var data = {
		"type": "move",
		"id": main.player_id,
		"x": position.x,
		"y": position.y
	}
	main.peer.send_text(JSON.stringify(data))
