extends Node

@export var pickup_scene: PackedScene
@export var rock_scene: PackedScene
@export var rock_sprites: Array[Texture2D] = []
@export var rock_count: int = 1200
@export var spawn_radius: float = 12000.0
@export var show_spawn_border: bool = true

func _ready() -> void:
	randomize()
	if rock_scene == null or pickup_scene == null:
		push_error("GameManager: Assign rock_scene and pickup_scene in the inspector.")
		return
	var rocks_container := Node2D.new()
	rocks_container.name = "RocksContainer"
	add_child(rocks_container)
	if show_spawn_border:
		_draw_border()

	# spawn rocks in batches for faster loading
	var batch_size = 50
	for i in range(rock_count):
		call_deferred("_spawn_rock", i, rocks_container, batch_size)
		
func _draw_border() -> void:
	var border = Line2D.new()
	border.width = 4
	border.default_color = Color.RED
	var segments = 128
	var points = []
	for i in range(segments + 1):
		points.append(Vector2(cos(TAU * i / segments), sin(TAU * i / segments)) * spawn_radius)
	border.points = points
	add_child(border)
	
func _spawn_rock(index: int, container: Node2D, batch_size: int) -> void:
	var rock = rock_scene.instantiate() as Node2D
	if rock == null:
		return
	# avoid clustering at center
	var angle = randf() * TAU
	var dist = sqrt(randf()) * spawn_radius
	rock.global_position = Vector2(cos(angle), sin(angle)) * dist
	# HP
	var base_hp = 3
	var extra_hp = int(dist / 800)
	rock.max_hp = base_hp + randi() % 3 + extra_hp
	rock.current_hp = rock.max_hp
	# scale
	var min_scale = 0.8
	var max_scale = 3.0
	var scale_factor = clamp(float(rock.max_hp) / 10.0, min_scale, max_scale)
	rock.scale = Vector2.ONE * scale_factor
	# pickups
	rock.drop_count = max(1, 1 + int(dist / 1000))
	rock.drops_pickup = pickup_scene
	# assign sprite tier
	if rock_sprites.size() > 0:
		var tier = clamp(rock.max_hp - base_hp, 0, rock_sprites.size() - 1)
		var sprite_node: Sprite2D = null
		if rock.has_node("PlaceholderRock"):
			sprite_node = rock.get_node("PlaceholderRock") as Sprite2D
		elif rock.has_node("Sprite2D"):
			sprite_node = rock.get_node("Sprite2D") as Sprite2D
		if sprite_node:
			sprite_node.texture = rock_sprites[tier]
	container.add_child(rock)
	if (index + 1) % batch_size == 0:
		await get_tree().process_frame
