extends Control

# --- Node references ---
@onready var subviewport_container: SubViewportContainer = $SubViewportContainer
@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var mini_camera: Camera2D = null
@onready var player: CharacterBody2D = $"../Player"  # Adjust path if needed

# --- Settings ---
var camera_name: String = "MiniMapCamera"
var offset: Vector2 = Vector2(10, 10)         # Distance from top-right corner
var follow_speed: float = 10.0                # Smooth follow speed

func _ready():
	# Get the camera inside the SubViewport
	if subviewport:
		mini_camera = subviewport.get_node_or_null(camera_name)
		if mini_camera:
			mini_camera.make_current()  # Activates camera for the subviewport
			subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			push_error("MiniMapCamera not found in SubViewport")
	else:
		push_error("SubViewport not found")

func _process(_delta):
	# 1. Stick the minimap to the top-right corner
	if subviewport_container:
		var viewport_size = get_viewport().get_visible_rect().size
		var container_size = subviewport_container.size
		position = Vector2(viewport_size.x - container_size.x - offset.x, offset.y)

	# 2. Smoothly move the minimap camera to follow the player
	if player and mini_camera:
		mini_camera.global_position = mini_camera.global_position.lerp(player.global_position, follow_speed * _delta)
