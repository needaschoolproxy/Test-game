extends Button
@onready var timer_2: Timer = $Timer2
@onready var quit_button: AnimatedSprite2D = $QuitButton



func _on_button_down() -> void:
	quit_button.play("down")


func _on_button_up() -> void:
	quit_button.play("up")


func _on_pressed() -> void:
	timer_2.start()
	



func _on_timer_2_timeout() -> void:
	get_tree().quit()
