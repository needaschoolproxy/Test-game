extends Node

@export var pickup_scene: PackedScene  

func _ready():
	randomize()
	for i in range(200):
		var rock = preload("res://scenes/rock.tscn").instantiate()
		var rand_x = randf_range(-2000, 2000)
		var rand_y = randf_range(-2000, 2000)
		rock.global_position = Vector2(rand_x, rand_y)
		if rock.has_method("take_damage"):
			rock.max_hp = randi() % 3 + 2  #hp(2 to 3)a
			rock.drops_pickup = pickup_scene
		add_child(rock)
