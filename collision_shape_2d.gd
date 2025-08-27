extends Node2D

@export var amount: int = 1  # how many items this pickup gives

func _ready():
	add_to_group("pickups")
