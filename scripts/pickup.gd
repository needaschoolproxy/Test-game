extends Area2D

@export var amount: int = 1
@export var magnet_speed: float = 200.0
@export var magnet_range: float = 200.0

@onready var player: Node = null

func _ready() -> void:
	add_to_group("pickups")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() == 0:
			return
		player = players[0]

	# move toward player if in range
	var dir = player.global_position - global_position
	var distance = dir.length()
	if distance < magnet_range:
		global_position += dir.normalized() * magnet_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.pickup_count += amount
		if body.has_method("_update_ui"):
			body._update_ui()
		queue_free()
