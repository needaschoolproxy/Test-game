extends Control

@onready var player: CharacterBody2D = $"../Player"
@onready var player_icon: Sprite2D = $PlayerIcon
@onready var rocks_container: Node2D = $RockIcons

var map_visible := false
var world_rect := Rect2(-2000, -2000, 4000, 4000)  # size of your world

func _ready():
	visible = false  # map starts hidden
	# Create rock icons for all rocks
	_refresh_rock_icons()

func _process(_delta):
	# Toggle map with M
	if Input.is_action_just_pressed("toggle_map"):
		map_visible = not map_visible
		visible = map_visible

	if map_visible:
		_update_map()

func _refresh_rock_icons():
	# Remove all existing icons
	for child in rocks_container.get_children():
		child.queue_free()

	# Add icons for all rocks
	var rocks = get_tree().get_nodes_in_group("rocks")
	for rock in rocks:
		var icon = Sprite2D.new()
		icon.texture = preload("res://Sprites/2.png")  # your rock icon
		icon.name = str(rock.get_instance_id())
		rocks_container.add_child(icon)


func _update_map():
	if not player:
		return

	# center the map on player
	var map_center = size / 2
	var player_map_pos = _world_to_map(player.global_position)
	var offset = map_center - player_map_pos

	# 
	

	# Move rocks
	for rock in get_tree().get_nodes_in_group("rocks"):
		var icon = rocks_container.get_node_or_null(str(rock.get_instance_id()))
		if icon:
			icon.position = _world_to_map(rock.global_position) + offset

# Convert world position to map position
func _world_to_map(world_pos: Vector2) -> Vector2:
	var map_size = size
	var x = ((world_pos.x - world_rect.position.x) / world_rect.size.x) * map_size.x
	var y = ((world_pos.y - world_rect.position.y) / world_rect.size.y) * map_size.y
	return Vector2(x, y)
