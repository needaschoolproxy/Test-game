extends Area2D

@export var upgrades = {
	"speed": {"cost": 5, "level": 0, "max_level": 3, "stat": "SPEED", "amount": 50},
	"damage": {"cost": 3, "level": 0, "max_level": 5, "stat": "DAMAGE", "amount": 1},
	"stamina": {"cost": 4, "level": 0, "max_level": 3, "stat": "stamina", "amount": 20}
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.show_upgrade_menu(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.hide_upgrade_menu()
