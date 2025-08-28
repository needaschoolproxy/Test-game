extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

const SPEED: float = 100.0
const ACCELERATION: float = 0.5
const FRICTION: float = 0.2
const ROCK_DETECT_RADIUS: float = 800.0
const ATTACK_COOLDOWN: float = 0.5

var direction: int = 1
var attack_timer: float = 0.0
var target_rock: Node2D = null

func _ready() -> void:
	timer.start()

func _process(delta: float) -> void:
	attack_timer = max(0.0, attack_timer - delta)
	var move_vector: Vector2 = Vector2.ZERO

	# acquire or validate target rock
	if not target_rock or not is_instance_valid(target_rock):
		target_rock = _get_highest_hp_rock()

	if target_rock:
		move_vector = (target_rock.global_position - global_position).normalized()
		_animate_direction(move_vector)

		if global_position.distance_to(target_rock.global_position) <= 20 and attack_timer <= 0:
			if target_rock.has_method("take_damage"):
				target_rock.take_damage(_calculate_damage(target_rock))
				attack_timer = ATTACK_COOLDOWN

		if target_rock.current_hp <= 0:
			target_rock = null
	else:
		move_vector = _get_random_direction()
		_animate_direction(move_vector)

	# movement smoothing
	if move_vector.length() > 0:
		velocity = velocity.lerp(move_vector * SPEED, ACCELERATION)
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)

	move_and_slide()

func _get_random_direction() -> Vector2:
	match direction:
		1: return Vector2(1, 0)
		2: return Vector2(-1, 0)
		3: return Vector2(0, 1)
		4: return Vector2(0, -1)
	return Vector2.ZERO

func _on_timer_timeout() -> void:
	direction = randi_range(1, 4)

func _get_highest_hp_rock() -> Node2D:
	var rocks = get_tree().get_nodes_in_group("rocks")
	var best_rock: Node2D = null
	var highest_hp: int = -1
	for rock in rocks:
		if "current_hp" in rock:
			var dist = global_position.distance_to(rock.global_position)
			if dist <= ROCK_DETECT_RADIUS and rock.current_hp > highest_hp:
				highest_hp = rock.current_hp
				best_rock = rock
	return best_rock

func _animate_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("right" if dir.x > 0 else "left")
	else:
		animated_sprite.play("down" if dir.y > 0 else "up")

func _calculate_damage(rock: Node2D) -> int:
	return max(1, int(rock.current_hp / 5))
