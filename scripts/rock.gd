extends Node2D
class_name Rock  

# rock hp
@export var max_hp: int = 3
var current_hp: int = 0

# pickups
@export var drops_pickup: PackedScene
@export var drop_count: int = 1

#sprites
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
	if has_node("HitParticles"):
		var particles = get_node("HitParticles") as CPUParticles2D
		particles.emitting = false
		particles.restart()
		particles.emitting = true

func _update_sprite_modulate() -> void:
	if has_node(sprite_node_name):
		var sprite = get_node(sprite_node_name) as Sprite2D
		if sprite:
			# fade 
			var t = clamp(float(current_hp)/float(max(1,max_hp)),0.0,1.0)
			sprite.modulate = Color(1,1,1,t)

func _spawn_pickups() -> void:
	if drops_pickup == null:
		push_warning("Rock has no drops_pickup assigned! Rock at: %s" % str(global_position))
		return

	for i in range(max(1, drop_count)):
		var pickup_instance = drops_pickup.instantiate()
		pickup_instance.global_position = global_position + Vector2(randf_range(-12,12), randf_range(-12,12))
		get_tree().current_scene.add_child(pickup_instance)
