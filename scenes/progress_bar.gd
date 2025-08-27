extends ProgressBar
@onready var progress_bar: ProgressBar = $"."
@onready var player: CharacterBody2D = $"../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = player.stamina
