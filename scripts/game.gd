extends Node2D

@onready var peer := WebSocketPeer.new()
var connected := false
var player_id := ""
var other_players := {}

@onready var local_player := $Player

func _ready():
	var err = peer.connect_to_url("ws://localhost:8080/ws")
	if err != OK:
		print("❌ Failed to connect: ", err)
	else:
		print("🔄 Connecting to ws://localhost:8080/ws...")
	set_process(true)

func _process(_delta):
	peer.poll()

	match peer.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not connected:
				connected = true
				print("✅ Connected to server")
			while peer.get_available_packet_count() > 0:
				var msg := peer.get_packet().get_string_from_utf8()
				_handle_message(msg)

func _handle_message(msg: String):
	var parsed = JSON.parse_string(msg)
	if parsed == null:
		print("❌ Failed to parse message:", msg)
		return

	var data = {}
	if parsed is Dictionary:
		data = parsed
	else:
		return

	match data.get("type", ""):
		"id":
			player_id = data["id"]
			print("Assigned Player ID:", player_id)

		"move":
			var id = data["id"]
			if id == player_id:
				return  # Don't update local player

			if not other_players.has(id):
				var new_player = preload("res://scenes/RemotePlayer.tscn").instantiate()
				add_child(new_player)
				other_players[id] = new_player
				print("🟢 Spawned remote player:", id)

			if other_players.has(id):
				other_players[id].set_target_position(Vector2(data["x"], data["y"]))

		"leave":
			var id = data["id"]
			if other_players.has(id):
				other_players[id].queue_free()
				other_players.erase(id)
				print("🔴 Removed player:", id)
