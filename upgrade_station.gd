extends Area2D

var upgrades = {
	"speed": {"cost": 5, "level": 0, "max_level": 3, "stat": "SPEED", "amount": 50},
	"damage": {"cost": 3, "level": 0, "max_level": 5, "stat": "DAMAGE", "amount": 1},
	"stamina": {"cost": 4, "level": 0, "max_level": 3, "stat": "stamina", "amount": 20}
}

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))


# ------------------------
# entering
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.show_upgrade_menu(self)


# ------------------------
#exiting
func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.hide_upgrade_menu()
