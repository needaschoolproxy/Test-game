extends StaticBody2D

signal poppup

func _on_goober_spawner_body_entered(_body: Node2D) -> void:
	emit_signal("poppup")
