extends Node2D

@export var max_hp: int = 3
var current_hp: int

@export var drops_pickup: PackedScene  #pickup stuff

func _ready():
	current_hp = max_hp
	add_to_group("rocks")

func take_damage(amount: int = 1):
	current_hp -= amount
	_trigger_hit_particles()
	if current_hp <= 0:
		_spawn_pickup()
		queue_free()

	#fade of rock
	if $PlaceholderRock:
		$PlaceholderRock.modulate = Color(1, 1, 1, float(current_hp) / float(max_hp))

func _trigger_hit_particles():
	if $HitParticles:
		$HitParticles.emitting = false  
		$HitParticles.restart()          
		$HitParticles.emitting = true

func _spawn_pickup():
	if drops_pickup:  
		var pickup_instance = drops_pickup.instantiate()
		pickup_instance.global_position = global_position
		get_tree().current_scene.add_child(pickup_instance)
