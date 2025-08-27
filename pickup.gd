extends Area2D 

@export var amount: int = 1
var magnet_speed: float = 200.0

func _ready():
	add_to_group("pickups")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	var player = players[0]
	var dir = player.global_position - global_position
	if dir.length() < 200:
		global_position += dir.normalized() * magnet_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_count += amount
		body._update_ui()
		queue_free()
