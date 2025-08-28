extends Control

# exported optional NodePath to your PLAYER (set in Inspector if you like)
@export var player_node: NodePath

@onready var button_container: VBoxContainer = $VBoxContainer
# fallback direct path (adjust if your tree differs)
@onready var _fallback_player = get_node_or_null("../../PLAYER")

var station: Node = null  # current UpgradeStation reference

# ------------------------
# Helper: get the player node robustly
func _get_player() -> Node:
	# prefer explicit exported path if set
	if player_node and player_node != NodePath(""):
		var p = get_node_or_null(player_node)
		if p:
			return p
	# fallback to found node at ../../PLAYER (common layout)
	if _fallback_player:
		return _fallback_player
	# last resort: check group "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

# ------------------------
# Clear all existing buttons
func _clear_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()

# ------------------------
# Populate buttons based on station.upgrades
func _populate_buttons() -> void:
	_clear_buttons()
	if not station:
		print_debug("UpgradeMenu: no station set, nothing to populate.")
		return

	if not station.has_method("upgrades") and not station.has_meta("upgrades") and not station.upgrades:
		# best-effort check; this line won't error if station.upgrades exists
		pass

	for upgrade_name in station.upgrades.keys():
		var upgrade = station.upgrades[upgrade_name]

		# wrapper to prevent VBox stretching children
		var hbox := HBoxContainer.new()
		# center horizontally in the VBox; BoxContainer.ALIGNMENT_CENTER works in 4.x
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		button_container.add_child(hbox)

		# create button
		var btn := Button.new()
		btn.text = "%s (Lv %d/%d) - %d" % [
			upgrade_name.capitalize(),
			upgrade["level"],
			upgrade["max_level"],
			upgrade["cost"]
		]
		btn.disabled = upgrade["level"] >= upgrade["max_level"]

		# force small fixed-ish size
		btn.custom_minimum_size = Vector2(140, 30)

		# IMPORTANT: capture loop var into local copy to avoid capture pitfalls
		var name_copy: String = String(upgrade_name)

		# connect using a small lambda that calls our handler with the copy
		btn.pressed.connect(func() -> void:
			_on_upgrade_pressed(name_copy)
		)

		# debug print so we know the button was made and connected
		print_debug("UpgradeMenu: created button for: ", name_copy)

		hbox.add_child(btn)

# ------------------------
# Called when a button is pressed
func _on_upgrade_pressed(upgrade_name: String) -> void:
	# debug
	print("UpgradeMenu: button pressed ->", upgrade_name)

	if not station:
		print("UpgradeMenu: no station active.")
		return

	# get player (robust)
	var ply = _get_player()
	if not ply:
		push_error("UpgradeMenu: Player node not found! Set player_node or add player to 'player' group.")
		return

	# sanity check upgrade exists
	if not station.upgrades.has(upgrade_name):
		push_error("UpgradeMenu: station has no upgrade named '%s'." % upgrade_name)
		return

	var upgrade = station.upgrades[upgrade_name]
	print_debug("UpgradeMenu: player pickups:", ply.pickup_count, "upgrade cost:", upgrade["cost"])

	# affordability check
	if ply.pickup_count >= upgrade["cost"]:
		# Deduct pickups
		ply.pickup_count -= upgrade["cost"]
		upgrade["level"] += 1

		# apply effect safely
		var stat_name = upgrade.get("stat", null)
		var amount = upgrade.get("amount", 0)
		if stat_name == null:
			push_error("UpgradeMenu: upgrade '%s' has no 'stat' field." % upgrade_name)
		else:
			# 
			if ply.has_method("get") or true:
				
				var cur = ply.get(stat_name)
				
				if cur == null:
					
					if ply.has_variable(stat_name):
						ply.set(stat_name, amount)
					else:
						push_error("UpgradeMenu: player has no stat/property named '%s'." % stat_name)
				else:
					# stuff
					ply.set(stat_name, cur + amount)

		# player UI 
		if ply.has_method("_update_ui"):
			ply._update_ui()

		# update labels/disable buttons
		_populate_buttons()
		print("UpgradeMenu: upgraded %s to level %d" % [upgrade_name, upgrade["level"]])
	else:
		print("UpgradeMenu: Not enough pickups! Have %d, need %d" % [ply.pickup_count, upgrade["cost"]])

# ------------------------
#menu api opening/closing
func open_menu(station_ref: Node) -> void:
	station = station_ref
	visible = true
	_populate_buttons()

func close_menu() -> void:
	visible = false
	_clear_buttons()
