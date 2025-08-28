extends Node2D

@export var amount: int = 1  # how many items given by the rcok pickup

func _ready():
	add_to_group("pickups")
