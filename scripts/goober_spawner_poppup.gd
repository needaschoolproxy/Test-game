extends Node2D
@onready var button_2: Button = $Button2
@onready var goobernumber: Label = $Goobernumber
@onready var player: CharacterBody2D = $".."




signal spawn_goober
var goobers = 0

func _on_button_pressed() -> void:
	visible = false


func _process(_delta: float) -> void:
	$Goobernumber.text = str(goobers)
	

func _on_button_2_pressed() -> void:
	if player. pickup_count >= 10:
		goobers += 1
		emit_signal("spawn_goober")
		player. pickup_count -= 10
		
