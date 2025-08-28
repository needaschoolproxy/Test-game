extends CharacterBody2D

var stamina = 100
var SPEED = 200.0
const ACCELERATION = 0.5
const FRICTION = 0.2
var SWING_OFFSET = 30
var SWING_RADIUS = 32
var SHAKE_AMOUNT = 4
var DAMAGE = 1

# refs
@onready var anim_sprite = $AnimatedSprite2D
@onready var swing_timer = $SwingTimer
@onready var camera = $Camera2D
@onready var swing_area = $Area2D
@onready var pickup_label = $"UI/PickupLabel" 
@onready var progress_bar: ProgressBar = $UI/ProgressBar

#state
var facing_dir := Vector2.DOWN
var is_swinging = false
var pickup_count: int = 0

func _ready():
	swing_area.monitoring = false
	if not swing_timer.is_connected("timeout", Callable(self, "_on_swing_timer_timeout")):
		swing_timer.timeout.connect(_on_swing_timer_timeout)
	_update_ui()
	add_to_group("player")  #pickup detection

#keybinds
func get_input() -> Vector2:
	var input = Vector2.ZERO
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("down"):
		input.y += 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	if Input.is_action_pressed("sprint") and stamina > 30:
		SPEED = 300
		stamina -= 1
	else: if Input.is_action_pressed("sprint") and stamina > 0:
		SPEED = 240
		stamina -= 1
	else: 
		SPEED = 200 
	return input

#physics
func _physics_process(_delta):
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

#anims
func play_walk_animation():
	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("walk_right" if facing_dir.x > 0 else "walk_left")
	else:
		anim_sprite.play("walk_down" if facing_dir.y > 0 else "walk_up")

func play_idle_animation():
	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("idle_right" if facing_dir.x > 0 else "idle_left")
	else:
		anim_sprite.play("idle_down" if facing_dir.y > 0 else "idle_up")

# swing of pick
func start_swing():
	is_swinging = true
	swing_area.position = facing_dir.normalized() * SWING_OFFSET

	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_sprite.play("swing_right" if facing_dir.x > 0 else "swing_left")
	else:
		anim_sprite.play("swing_down" if facing_dir.y > 0 else "swing_up")

	await get_tree().process_frame
	_hit_nearby_rocks()

	swing_timer.start()

func _on_swing_timer_timeout():
	is_swinging = false

func _hit_nearby_rocks():
	var rocks = get_tree().get_nodes_in_group("rocks")
	for rock in rocks:
		if rock.global_position.distance_to(global_position + facing_dir.normalized() * SWING_OFFSET) <= SWING_RADIUS:
			if rock.has_method("take_damage"):
				print("Rock hit:", rock)
				rock.take_damage(DAMAGE)
				_screen_shake()

#shake when pick hit
func _screen_shake():
	if not camera:
		return
	var original_pos = camera.position
	var offset = Vector2(randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT),
						 randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT))
	camera.position = original_pos + offset
	await get_tree().process_frame
	camera.position = original_pos

#UI(doesnt really work)
func _update_ui():
	if pickup_label:
		pickup_label.text = str(pickup_count)

func _process(_delta: float) -> void:
	if not Input.is_action_pressed("sprint") and stamina < 100: 
		stamina += 0.5
	if stamina == 100 and not Input.is_action_pressed("sprint"):
		progress_bar.visible = false
	else: progress_bar.visible = true
