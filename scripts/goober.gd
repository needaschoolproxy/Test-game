extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var direction = 1
const SPEED = 100.0
const ACCELERATION = 0.5
const FRICTION = 0.2
const ROCK_DETECT_RADIUS = 200.0
const ATTACK_COOLDOWN = 0.5

var attack_timer := 0.0
var target_rock: Node2D = null  # Persistent target

func _ready() -> void:
	timer.start()

func _process(delta):
	attack_timer -= delta

	var move_vector = Vector2.ZERO

	# --- Acquire target if needed ---
	if target_rock == null or not is_instance_valid(target_rock):
		target_rock = _get_highest_hp_rock()

	# --- Move and attack ---
	if target_rock:
		move_vector = (target_rock.global_position - global_position).normalized()
		_animate_direction(move_vector)

		# Attack if close enough
		if global_position.distance_to(target_rock.global_position) <= 20:
			if target_rock.has_method("take_damage") and attack_timer <= 0:
				var damage = _calculate_damage(target_rock)
				target_rock.take_damage(damage)
				attack_timer = ATTACK_COOLDOWN

		# Clear target if rock is destroyed
		if target_rock.current_hp <= 0:
			target_rock = null
	else:
		# Random wandering when no target
		move_vector = _get_random_direction()
		_animate_direction(move_vector)

	# --- Movement ---
	if move_vector.length() > 0:
		velocity = velocity.lerp(move_vector * SPEED, ACCELERATION)
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)

	move_and_slide()

func _get_random_direction() -> Vector2:
	var input = Vector2()
	if direction == 1:
		input.x += 1
	if direction == 2:
		input.x -= 1
	if direction == 3:
		input.y += 1
	if direction == 4:
		input.y -= 1
	return input

func _on_timer_timeout() -> void:
	direction = randi_range(1, 4)

# --- Find the rock with the highest HP within detection radius ---
func _get_highest_hp_rock() -> Node2D:
	var rocks = get_tree().get_nodes_in_group("rocks")
	var best_rock: Node2D = null
	var highest_hp = -1
	for rock in rocks:
		if "current_hp" in rock:
			var d = global_position.distance_to(rock.global_position)
			if d <= ROCK_DETECT_RADIUS and rock.current_hp > highest_hp:
				highest_hp = rock.current_hp
				best_rock = rock
	return best_rock

func _animate_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite_2d.play("right" if dir.x > 0 else "left")
	else:
		animated_sprite_2d.play("down" if dir.y > 0 else "up")

func _calculate_damage(rock: Node2D) -> int:
	if not rock.has_method("take_damage") or not ("current_hp" in rock):
		return 1
	return max(1, int(rock.current_hp / 5))
