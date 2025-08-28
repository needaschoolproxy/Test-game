extends Node2D

@export var enemy_scene: PackedScene          # Enemy.tscn
@export var spawn_radius: float = 400.0       # Distance around spawner
@export var max_enemies: int = 5              # Limit at once
@export var spawn_interval: float = 3.0       # Seconds between spawns

@onready var spawn_timer: Timer = $spawn_timer

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		_spawn_enemy()

func _spawn_enemy() -> void:
	if enemy_scene == null:
		return

	var enemy = enemy_scene.instantiate()
	var angle = randf() * TAU
	var radius = sqrt(randf()) * spawn_radius  # Spread evenly, avoid center clustering
	enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * radius

	get_tree().current_scene.add_child(enemy)
