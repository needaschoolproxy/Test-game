extends Node2D
class_name Rock  
@export var max_hp: int = 3
var current_hp: int = 0
@export var drops_pickup: PackedScene
@export var drop_count: int = 1
@export var sprite_node_name: NodePath = "PlaceholderRock"

func _ready() -> void:
	current_hp = max_hp
	add_to_group("rocks")
	_update_sprite_modulate()
	
func take_damage(amount: int = 1) -> void:
	current_hp -= amount
	_trigger_hit_particles()
	if current_hp <= 0:
		_spawn_pickups()
		queue_free()
	else:
		_update_sprite_modulate()
		
func _trigger_hit_particles() -> void:
	var particles = get_node_or_null("HitParticles")
	if particles:
		particles.emitting = false
		particles.restart()
		particles.emitting = true
		
func _update_sprite_modulate() -> void:
	var sprite = get_node_or_null(sprite_node_name)
	if sprite:
		var t = clamp(float(current_hp) / float(max(1, max_hp)), 0.0, 1.0)
		sprite.modulate = Color(1, 1, 1, t)
		
func _spawn_pickups() -> void:
	if not drops_pickup:
		return
	for i in range(max(1, drop_count)):
		var pickup_instance = drops_pickup.instantiate()
		pickup_instance.global_position = global_position + Vector2(randf_range(-12,12), randf_range(-12,12))
		get_tree().current_scene.add_child(pickup_instance)
