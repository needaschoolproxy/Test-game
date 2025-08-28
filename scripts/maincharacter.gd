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
var max_goobers: int = 3
var gooberscene = preload("res://scenes/goober.tscn")

# ------------------------
# references / UI
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_timer: Timer = $SwingTimer
@onready var camera: Camera2D = $Camera2D
@onready var swing_area: Area2D = $Area2D
@onready var pickup_label: Label = $"UI/PickupLabel"
@onready var progressbar: ProgressBar = $"UI/ProgressBar"
@onready var upgrade_menu: Control = $"UI/UpgradeMenu"
@onready var goober_popup: Control = $"UI/GooberSpawnerPopup"

# ------------------------
# player state
var facing_dir: Vector2 = Vector2.DOWN
var is_swinging: bool = false
var pickup_count: int = 0

# reference to the spawner the player is currently touching
var current_spawner: Node = null

# ------------------------
# setup
func _ready() -> void:
	swing_area.monitoring = false
	if not swing_timer.is_connected("timeout", Callable(self, "_on_swing_timer_timeout")):
		swing_timer.timeout.connect(_on_swing_timer_timeout)
	add_to_group("player")
	_update_ui()

	# hide the goober popup initially
	if goober_popup:
		goober_popup.visible = false

# ------------------------
# spawner interaction
func set_current_spawner(spawner: Node) -> void:
	current_spawner = spawner
	if goober_popup:
		goober_popup.visible = true

func clear_current_spawner(spawner: Node) -> void:
	if current_spawner == spawner:
		current_spawner = null
		if goober_popup:
			goober_popup.visible = false

# ------------------------
# input handling
func get_input() -> Vector2:
	var input: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("down"):
		input.y += 1
	if Input.is_action_pressed("up"):
		input.y -= 1

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

	move_and_slide()

	if Input.is_action_just_pressed("swing") and not is_swinging:
		start_swing()

	if not Input.is_action_pressed("sprint") and stamina < 100:
		stamina += 20 * delta
	stamina = clamp(stamina, 0, 100)
	progressbar.value = stamina
	progressbar.visible = stamina < 100

	if Input.is_action_just_pressed("reset_game"):
		_reset_to_menu()

# ------------------------
# reset
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
	_hit_nearby_rocks()
	swing_timer.start()

func _on_swing_timer_timeout() -> void:
	is_swinging = false

func _hit_nearby_rocks() -> void:
	var rocks = get_tree().get_nodes_in_group("rocks")
	for rock in rocks:
		if rock.global_position.distance_to(global_position + facing_dir.normalized() * SWING_OFFSET) <= SWING_RADIUS:
			if rock.has_method("take_damage"):
				rock.take_damage(DAMAGE)
				_screen_shake()

func _screen_shake() -> void:
	if not camera:
		return
	var original_pos = camera.position
	var offset = Vector2(randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT), randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT))
	camera.position = original_pos + offset
	await get_tree().process_frame
	camera.position = original_pos

# ------------------------
# UI
func _update_ui() -> void:
	if pickup_label:
		pickup_label.text = str(pickup_count)

# ------------------------
# upgrade menu
func show_upgrade_menu(station: Node) -> void:
	if upgrade_menu:
		upgrade_menu.open_menu(station)

func hide_upgrade_menu() -> void:
	if upgrade_menu:
		upgrade_menu.close_menu()
