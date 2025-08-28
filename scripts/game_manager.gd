extends Node

@export var pickup_scene: PackedScene
@export var rock_scene: PackedScene
@export var rock_sprites: Array[Texture2D] = []

@export var rock_count: int = 1200
@export var spawn_radius: float = 12000.0
@export var show_spawn_border: bool = true  #border

func _ready() -> void:
	randomize()

	if rock_scene == null:
		push_error("GameManager: rock_scene is null! Assign rock.tscn in the inspector.")
		return
	if pickup_scene == null:
		push_error("GameManager: pickup_scene is null! Assign pickup.tscn in the inspector.")
		return

	var rocks_container := Node2D.new()
	rocks_container.name = "RocksContainer"
	add_child(rocks_container)

	
	if show_spawn_border:
		var border := Line2D.new()
		border.width = 4
		border.default_color = Color.RED
		var points := []
		var segments = 128
		for i in range(segments + 1):
			var angle = TAU * i / segments
			points.append(Vector2(cos(angle), sin(angle)) * spawn_radius)
		border.points = points
		add_child(border)

	# spawn rocks
	for i in range(rock_count):
		var rock = rock_scene.instantiate() as Node2D
		if rock == null:
			push_warning("Failed to instantiate rock")
			continue

		# distribute rocks
		var angle = randf() * TAU
		var dist = sqrt(randf()) * spawn_radius  #cluster fix
		rock.global_position = Vector2(cos(angle), sin(angle)) * dist

		#HP
		var base_hp = 3
		var extra_hp = int(dist / 800)
		rock.max_hp = base_hp + randi() % 3 + extra_hp
		rock.current_hp = rock.max_hp

		#scale
		var min_scale = 0.8
		var max_scale = 3.0
		var scale_factor = clamp(float(rock.max_hp) / 10.0, min_scale, max_scale)
		rock.scale = Vector2.ONE * scale_factor

		# pickups
		rock.drop_count = max(1, 1 + int(dist / 1000))
		rock.drops_pickup = pickup_scene

		# sprite tier if available
		if rock_sprites.size() > 0:
			var tier = clamp(rock.max_hp - base_hp, 0, rock_sprites.size() - 1)
			var sprite_node: Sprite2D = null
			if rock.has_node("PlaceholderRock"):
				sprite_node = rock.get_node("PlaceholderRock") as Sprite2D
			elif rock.has_node("Sprite2D"):
				sprite_node = rock.get_node("Sprite2D") as Sprite2D
			if sprite_node:
				sprite_node.texture = rock_sprites[tier]

		rocks_container.add_child(rock)
