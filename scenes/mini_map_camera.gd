extends Camera2D

@onready var player = get_tree().get_root().get_node("MainScene/Player") # adjust path

func _process(_delta):
	if player:
		global_position = player.global_position
