extends ProgressBar
@onready var progress_bar: ProgressBar = $"."
@onready var player: CharacterBody2D = $"../.."

# delta is time or smnth
func _process(_delta: float) -> void:
	value = player.stamina
	if player.stamina < 30:
		progress_bar.get("theme_override_styles/fill").bg_color = Color.CORNFLOWER_BLUE
	else: progress_bar.get("theme_override_styles/fill").bg_color = Color.SKY_BLUE
