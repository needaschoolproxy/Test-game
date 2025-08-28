extends CharacterBody2D

# ------------------------
# exported stats
@export var speed: float = 120.0
@export var view_range: float = 250.0
@export var max_hp: int = 3
@export var damage: int = 1                   # damage to player
@export var drops_pickup: PackedScene
@export var drop_count: int = 2
@export var knockback_force: float = 200.0
@export var attack_cooldown: float = 1.0      # seconds between attacks

# ------------------------
# state
var current_hp: int
var player: Node2D
var is_flashing: bool = false
var attack_timer: float = 0.0

# ------------------------
# references
@onready var sprite: Sprite2D = $Sprite2D
@onready var flash_timer: Timer = $FlashTimer

# ------------------------
# setup
func _ready():
	current_hp = max_hp
	flash_timer.wait_time = 0.15
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timer_timeout)
	add_to_group("enemies")

# ------------------------
# movement AI
func _physics_process(delta: float) -> void:
	# reduce attack timer
	if attack_timer > 0:
		attack_timer -= delta

	# find player
	if not player or !is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	# chase player if in view range
	if player and global_position.distance_to(player.global_position) < view_range:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# check collision with player to deal damage
	if player and global_position.distance_to(player.global_position) < 16:
		_attack_player(player)

# ------------------------
# take damage from player swing
func take_damage(amount: int, attacker: Node2D) -> void:
	if is_flashing:
		return

	current_hp -= amount
	_flash_white()

	# knockback the attacker slightly
	if attacker and attacker.is_in_group("player") and attacker.has_method("apply_knockback"):
		var dir = (attacker.global_position - global_position).normalized()
		attacker.apply_knockback(dir * knockback_force)

	# die if hp <= 0
	if current_hp <= 0:
		_die()

# ------------------------
# flash effect
func _flash_white():
	is_flashing = true
	sprite.modulate = Color(1, 1, 1)  # full white
	flash_timer.start()

func _on_flash_timer_timeout():
	is_flashing = false
	sprite.modulate = Color(1, 1, 1)  # reset to normal

# ------------------------
# attack player
func _attack_player(player_node: Node2D):
	if attack_timer > 0:
		return  # still cooling down
	if not player_node.has_method("take_damage"):
		return

	# deal damage
	player_node.take_damage(damage, global_position)

	# reset cooldown
	attack_timer = attack_cooldown

# ------------------------
# death
func _die():
	_spawn_pickups()
	queue_free()

func _spawn_pickups():
	if drops_pickup == null:
		push_warning("Enemy has no drops_pickup assigned!")
		return

	for i in range(drop_count):
		var pickup = drops_pickup.instantiate()
		pickup.global_position = global_position + Vector2(randf_range(-12, 12), randf_range(-12, 12))
		get_tree().current_scene.add_child(pickup)
