extends CharacterBody2D

const SPEED = 200.0
const ACCELERATION = 0.5
const FRICTION = 0.2

@onready var anim_sprite = $AnimatedSprite2D
@onready var swing_area = $Area2D

var facing_dir := Vector2.DOWN 
var is_swinging = false

func get_input() -> Vector2:
	var input = Vector2()
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("down"):
		input.y += 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	return input

func _process(delta):
	var direction = get_input()
	
	#movement when swinging
	if is_swinging:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	#movement 'logic'?
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * SPEED, ACCELERATION)
		facing_dir = direction.normalized()
		play_walk_animation()
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)
		play_idle_animation()
	
	move_and_slide()
	
	#swing input thing
	if Input.is_action_just_pressed("swing") and not is_swinging:
		start_swing()

#animation stuff

func play_walk_animation():
	if abs(facing_dir.x) > abs(facing_dir.y):
		if facing_dir.x > 0:
			anim_sprite.play("walk_right")
		else:
			anim_sprite.play("walk_left")
	else:
		if facing_dir.y > 0:
			anim_sprite.play("walk_down")
		else:
			anim_sprite.play("walk_up")

func play_idle_animation():
	if abs(facing_dir.x) > abs(facing_dir.y):
		if facing_dir.x > 0:
			anim_sprite.play("idle_right")
		else:
			anim_sprite.play("idle_left")
	else:
		if facing_dir.y > 0:
			anim_sprite.play("idle_down")
		else:
			anim_sprite.play("idle_up")

#pickaxe swing and such

func start_swing():
	is_swinging = true
	swing_area.monitoring = true  #turn on hitbox
	
	#swing direction
	if abs(facing_dir.x) > abs(facing_dir.y):
		if facing_dir.x > 0:
			anim_sprite.play("swing_right")
		else:
			anim_sprite.play("swing_left")
	else:
		if facing_dir.y > 0:
			anim_sprite.play("swing_down")
		else:
			anim_sprite.play("swing_up")


	if not anim_sprite.is_connected("animation_finished", Callable(self, "_on_swing_finished")):
		anim_sprite.connect("animation_finished", Callable(self, "_on_swing_finished"))

	
func _on_swing_finished():
	#player resets after swinging
	swing_area.monitoring = false
	is_swinging = false
