extends Node

var rand_x
var rand_y

func _ready():
	randomize()
	for i in range(200):
		var rock = preload("res://scenes/rock.tscn").instantiate()
		rand_x = randf_range(-2000,2000)
		rand_y = randf_range(-2000,2000)
		rock.global_position = Vector2(rand_x,rand_y)
		add_child(rock)
	
