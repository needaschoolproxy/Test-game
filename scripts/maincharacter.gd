extends CharacterBody2D

# ------------------------
# stats
var stamina: float = 100
var SPEED: float = 200.0
const ACCELERATION: float = 0.5
const FRICTION: float = 0.2
var SWING_OFFSET: float = 30
var SWING_RADIUS: float = 32
var SHAKE_AMOUNT: float = 4
var DAMAGE: int = 1

# health
var max_health: int = 5
var health: int = max_health

# knockback (applies additively, does not block player input)
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 6.0

# how much knockback the player's swing applies to enemies
const PLAYER_KNOCKBACK_FORCE: float = 200.0

var gooberscene: PackedScene = preload("res://scenes/goober.tscn")
var max_goobers: int = 3

# ------------------------
# node refs (use get_node_or_null for safety)
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_timer: Timer = $SwingTimer
@onready var camera: Camera2D = $Camera2D
@onready var swing_area: Area2D = $Area2D

@onready var pickup_label: Label = get_node_or_null("UI/PickupLabel") as Label
@onready var progressbar: ProgressBar = get_node_or_null("UI/ProgressBar") as ProgressBar
@onready var upgrade_menu: Control = get_node_or_null("UI/UpgradeMenu") as Control
@onready var goober_popup: Control = get_node_or_null("UI/GooberSpawnerPoppup") as Control  # note spelling from your project
@onready var hpbar: ProgressBar = get_node_or_null("UI/HPBar") as ProgressBar

# flash timer (for damage flash)
var flash_timer: Timer

# ------------------------
# state
var facing_dir: Vector2 = Vector2.DOWN
var is_swinging: bool = false
var pickup_count: int = 0

# current spawner the player is touching (assigned by spawner Area2D)
var current_spawner: Node = null

var is_flashing: bool = false

# ------------------------
func _ready() -> void:
	# swing timer connection
	if not swing_timer.is_connected("timeout", Callable(self, "_on_swing_timer_timeout")):
		swing_timer.timeout.connect(_on_swing_timer_timeout)

	add_to_group("player")
	_update_ui()

	# hide popup safely
	if goober_popup:
		goober_popup.visible = false

	# hpbar
	health = max_health
	if hpbar:
		hpbar.max_value = max_health
		hpbar.value = health

	# flash timer (for damage flash)
	flash_timer = Timer.new()
	flash_timer.one_shot = true
	flash_timer.wait_time = 0.15
	add_child(flash_timer)

# ------------------------
# spawner API (called by the Area2D spawner)
func set_current_spawner(spawner: Node) -> void:
	current_spawner = spawner
	if goober_popup:
		goober_popup.visible = true

func clear_current_spawner(spawner: Node) -> void:
	if current_spawner == spawner:
		current_spawner = null
		if goober_popup:
			goober_popup.visible = false

# optional: call from popup button to spawn (spawner still controls location)
func spawn_goober_from_spawner() -> void:
	if not current_spawner:
		return
	# optional: restrict total enemies/goobers
	var current = get_tree().get_nodes_in_group("enemies").size()
	if current >= max_goobers:
		return
	if not gooberscene:
		return
	var g = gooberscene.instantiate()
	get_tree().current_scene.add_child(g)
	g.global_position = current_spawner.global_position

# ------------------------
# input handling
func get_input() -> Vector2:
	var input: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("right"): input.x += 1
	if Input.is_action_pressed("left"): input.x -= 1
	if Input.is_action_pressed("down"): input.y += 1
	if Input.is_action_pressed("up"): input.y -= 1

	if Input.is_action_pressed("sprint") and stamina > 0:
		SPEED = 300
		stamina -= 30 * get_process_delta_time()
	else:
		SPEED = 200
	return input

# ------------------------
# physics
func _physics_process(delta: float) -> void:
	var direction = get_input()

	# movement while allowing knockback additive effect
	if is_swinging:
		velocity = Vector2.ZERO
	else:
		if direction.length() > 0:
			velocity = velocity.lerp(direction.normalized() * SPEED, ACCELERATION)
			facing_dir = direction.normalized()
			play_walk_animation()
		else:
			velocity = velocity.lerp(Vector2.ZERO, FRICTION)
			play_idle_animation()

	# apply knockback additive
	if knockback_velocity.length() > 0.1:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, KNOCKBACK_DECAY * delta)

	move_and_slide()

	# swing input
	if Input.is_action_just_pressed("swing") and not is_swinging:
		start_swing()

	# stamina regen + UI
	if not Input.is_action_pressed("sprint") and stamina < 100:
		stamina += 20 * delta
	stamina = clamp(stamina, 0, 100)
	if progressbar:
		progressbar.value = stamina
		progressbar.visible = stamina < 100

	# reset
	if Input.is_action_just_pressed("reset_game"):
		_reset_to_menu()

# ------------------------
func _reset_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ------------------------
# animations
func play_walk_animation() -> void:
	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("walk_right" if facing_dir.x > 0 else "walk_left")
	else:
		anim_sprite.play("walk_down" if facing_dir.y > 0 else "walk_up")

func play_idle_animation() -> void:
	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("idle_right" if facing_dir.x > 0 else "idle_left")
	else:
		anim_sprite.play("idle_down" if facing_dir.y > 0 else "idle_up")

# ------------------------
# swing
func start_swing() -> void:
	is_swinging = true
	swing_area.position = facing_dir.normalized() * SWING_OFFSET

	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("swing_right" if facing_dir.x > 0 else "swing_left")
	else:
		anim_sprite.play("swing_down" if facing_dir.y > 0 else "swing_up")

	await get_tree().process_frame
	_hit_nearby_targets()
	swing_timer.start()

func _on_swing_timer_timeout() -> void:
	is_swinging = false

# ------------------------
# hit detection: both rocks and enemies
func _hit_nearby_targets() -> void:
	var swing_pos = global_position + facing_dir.normalized() * SWING_OFFSET

	# rocks (use existing rock logic)
	for rock in get_tree().get_nodes_in_group("rocks"):
		if rock.global_position.distance_to(swing_pos) <= SWING_RADIUS:
			if rock.has_method("take_damage"):
				rock.take_damage(DAMAGE)
				_screen_shake()

	# enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(swing_pos) <= SWING_RADIUS:
			if enemy.has_method("take_damage"):
				enemy.take_damage(DAMAGE, self)  # enemy expects (amount, attacker:Node)
			# apply knockback on enemy if they provide an API or manually nudge them
			if enemy.has_method("apply_knockback"):
				var dir = (enemy.global_position - global_position).normalized()
				enemy.apply_knockback(dir * PLAYER_KNOCKBACK_FORCE)
			else:
				# fallback: small manual nudge
				enemy.global_position += (enemy.global_position - global_position).normalized() * 8

# ------------------------
func _screen_shake() -> void:
	if not camera:
		return
	var original_pos = camera.position
	camera.position = original_pos + Vector2(randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT), randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT))
	await get_tree().process_frame
	camera.position = original_pos

# ------------------------
# damage received from enemies (called by enemy.take_damage/attack code)
func take_damage(amount: int, source_position: Vector2) -> void:
	# optional invulnerability / flashing handled by is_flashing
	if is_flashing:
		return
	health -= amount
	_update_hpbar()

	# flash visual
	_flash_hit()

	# knockback away from source
	var dir = (global_position - source_position).normalized()
	# set an additive knockback velocity (doesn't block input)
	knockback_velocity += dir * 300

	if health <= 0:
		_die()

# flash helpers
func _flash_hit() -> void:
	is_flashing = true
	if anim_sprite:
		anim_sprite.modulate = Color(1, 0.5, 0.5)
	flash_timer.start()
	# wait for timer signal
	await flash_timer.timeout
	is_flashing = false
	if anim_sprite:
		anim_sprite.modulate = Color(1, 1, 1)

# ------------------------
func _update_hpbar() -> void:
	if hpbar:
		hpbar.value = health

func _die() -> void:
	# simple reload on death
	get_tree().reload_current_scene()

# ------------------------
# UI
func _update_ui() -> void:
	if pickup_label:
		pickup_label.text = str(pickup_count)

func show_upgrade_menu(station: Node) -> void:
	if upgrade_menu:
		upgrade_menu.open_menu(station)

func hide_upgrade_menu() -> void:
	if upgrade_menu:
		upgrade_menu.close_menu()
