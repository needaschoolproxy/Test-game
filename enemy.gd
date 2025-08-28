extends CharacterBody2D

# ------------------------
# exported stats
@export var speed: float = 120.0
@export var view_range: float = 250.0
@export var max_hp: int = 3
@export var damage: int = 1
@export var drops_pickup: PackedScene
@export var drop_count: int = 2
@export var knockback_force: float = 200.0
@export var attack_cooldown: float = 1.0

# ------------------------
# state
var current_hp: int
var player: Node2D
var is_flashing: bool = false
var attack_timer: float = 0.0
var spawn_position: Vector2

# ------------------------
# references
@onready var sprite: Sprite2D = $Sprite2D
@onready var flash_timer: Timer = $FlashTimer

# ------------------------
# setup
func _ready() -> void:
	current_hp = max_hp
	spawn_position = global_position

	# scale strength based on distance from spawn
	_scale_strength_by_distance()

	flash_timer.wait_time = 0.15
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timer_timeout)
	add_to_group("enemies")

# ------------------------
# scale enemy HP and damage by distance to spawn
func _scale_strength_by_distance() -> void:
	if not player or not is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	if player:
		var dist = spawn_position.distance_to(player.global_position)
		current_hp += int(dist / 500)   # +1 HP per 500 units
		damage += int(dist / 600)       # +1 damage per 600 units

# ------------------------
# movement AI
func _physics_process(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta

	if not player or !is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	if player:
		var dist_to_player = global_position.distance_to(player.global_position)
		if dist_to_player < view_range:
			var dir = (player.global_position - global_position).normalized()
			velocity = dir * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if player and global_position.distance_to(player.global_position) < 16:
		_attack_player(player)

# ------------------------
# take damage
func take_damage(amount: int, attacker: Node2D) -> void:
	if is_flashing:
		return

	current_hp -= amount
	_flash_white()

	if attacker and attacker.is_in_group("player") and attacker.has_method("apply_knockback"):
		var dir = (attacker.global_position - global_position).normalized()
		attacker.apply_knockback(dir * knockback_force)

	if current_hp <= 0:
		_die()

# ------------------------
# flash effect
func _flash_white() -> void:
	is_flashing = true
	sprite.modulate = Color(1, 1, 1)
	flash_timer.start()

func _on_flash_timer_timeout() -> void:
	is_flashing = false
	sprite.modulate = Color(1, 1, 1)

# ------------------------
# attack player
func _attack_player(player_node: Node2D) -> void:
	if attack_timer > 0 or not player_node.has_method("take_damage"):
		return

	player_node.take_damage(damage, global_position)
	attack_timer = attack_cooldown

# ------------------------
# death
func _die() -> void:
	_spawn_pickups()
	queue_free()

# ------------------------
# pickups
func _spawn_pickups() -> void:
	if drops_pickup == null:
		return

	for i in range(drop_count):
		var pickup = drops_pickup.instantiate()
		pickup.global_position = global_position + Vector2(randf_range(-12, 12), randf_range(-12, 12))
		get_tree().current_scene.add_child(pickup)
