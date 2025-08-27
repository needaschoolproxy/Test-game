extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var direction = 1
const SPEED = 100.0
const acceleration = 0.5
const friction = 0.2

func _ready() -> void:
	timer.start()

func get_input():
	var input = Vector2()
	if direction == 1:
		input.x += 1
		animated_sprite_2d.play("right")
	if direction == 2:
		input.x -= 1
		animated_sprite_2d.play("left")
	if direction == 3:
		input.y += 1
		animated_sprite_2d.play("down")
	if direction == 4:
		input.y -= 1
		animated_sprite_2d.play("up")
	return input

func _process(_delta):
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * SPEED, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	move_and_slide()

func _on_timer_timeout() -> void:
	direction = randi_range(1,4)
	
