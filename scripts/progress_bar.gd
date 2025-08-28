extends ProgressBar
@onready var player: CharacterBody2D = $"../.."
@onready var fill_style = get("theme_override_styles/fill")
var low_color: Color = Color.CORNFLOWER_BLUE
var high_color: Color = Color.SKY_BLUE

func _process(_delta: float) -> void:
	value = player.stamina
	var t = clamp(player.stamina / player.stamina_max, 0.0, 1.0)
	fill_style.bg_color = low_color.lerp(high_color, t)
