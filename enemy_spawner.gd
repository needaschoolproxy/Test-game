extends Node2D

@export var enemy_scene: PackedScene         # Enemy.tscn
@export var spawn_radius: float = 400.0      # Distance around spawner
@export var max_enemies: int = 5             # Limit at once
@export var spawn_interval: float = 3.0      # Seconds between spawns

@onready var spawn_timer: Timer = $spawn_timer

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if enemy_count >= max_enemies:
		return

	_spawn_enemy()

func _spawn_enemy():
	if enemy_scene == null:
		push_warning("EnemySpawner has no enemy_scene set!")
		return

	var enemy = enemy_scene.instantiate()
	
	# Random position in circle around spawner
	var angle = randf() * TAU
	var radius = randf() * spawn_radius
	var offset = Vector2(cos(angle), sin(angle)) * radius

	enemy.global_position = global_position + offset
	get_tree().current_scene.add_child(enemy)
