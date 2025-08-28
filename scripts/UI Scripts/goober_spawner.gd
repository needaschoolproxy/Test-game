extends Area2D

@export var goober_scene: PackedScene
@export var max_goobers: int = 3

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
	
		body.set_current_spawner(self)
		_spawn_goober()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.clear_current_spawner(self)

func _spawn_goober() -> void:
	if not goober_scene:
		push_warning("GooberSpawner: no goober_scene assigned!")
		return

	# count existing goobers
	var current = get_tree().get_nodes_in_group("enemies").size()
	if current >= max_goobers:
		return

	
	var goober = goober_scene.instantiate()
	get_tree().current_scene.add_child(goober)
	goober.global_position = global_position
