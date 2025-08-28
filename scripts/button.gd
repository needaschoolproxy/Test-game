extends Button
@onready var play_button: AnimatedSprite2D = $PlayButton
@onready var timer: Timer = $Timer



func _on_button_up() -> void:
	play_button.play("Up")


func _on_button_down() -> void:
	play_button.play("Down")


func _on_pressed() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/mainscene.tscn")
