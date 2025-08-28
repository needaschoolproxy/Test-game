extends StaticBody2D

@export var goober_scene: PackedScene
@export var max_goobers: int = 3
@export var popup_ui: Control  # assign GooberSpawnerPopup here

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	if popup_ui:
		popup_ui.visible = false  # hide by default

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if popup_ui:
			popup_ui.visible = true
		_spawn_goober()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and popup_ui:
		popup_ui.visible = false

func _spawn_goober() -> void:
	if not goober_scene:
		push_warning("GooberSpawner: no goober_scene assigned!")
		return

	# count existing goobers
	var current = get_tree().get_nodes_in_group("enemies").size()
	if current >= max_goobers:
		return

	# instantiate and add to scene
	var goober = goober_scene.instantiate()
	get_tree().current_scene.add_child(goober)
	goober.global_position = global_position
