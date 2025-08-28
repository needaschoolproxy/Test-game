extends Control

@export var player_node: NodePath

@onready var button_container: VBoxContainer = $VBoxContainer
@onready var _fallback_player = get_node_or_null("../../PLAYER")

var station: Node = null  # current UpgradeStation ref


#get the player node
func _get_player() -> Node:
	if player_node and player_node != NodePath(""):
		var p = get_node_or_null(player_node)
		if p:
			return p
	if _fallback_player:
		return _fallback_player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null


# clear buttons
func _clear_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()


#buttons
func _populate_buttons() -> void:
	_clear_buttons()
	if not station:
		return
	if not station.upgrades:
		return

	for upgrade_name in station.upgrades.keys():
		var upgrade = station.upgrades[upgrade_name]
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		button_container.add_child(hbox)

		var btn := Button.new()
		btn.text = "%s (Lv %d/%d) - %d" % [
			upgrade_name.capitalize(),
			upgrade["level"],
			upgrade["max_level"],
			upgrade["cost"]
		]
		btn.disabled = upgrade["level"] >= upgrade["max_level"]
		btn.custom_minimum_size = Vector2(140, 30)

		var name_copy: String = String(upgrade_name)
		btn.pressed.connect(func() -> void:
			_on_upgrade_pressed(name_copy)
		)

		hbox.add_child(btn)

#upgrd purchases
func _on_upgrade_pressed(upgrade_name: String) -> void:
	if not station:
		return
	var ply = _get_player()
	if not ply:
		return
	if not station.upgrades.has(upgrade_name):
		return

	var upgrade = station.upgrades[upgrade_name]
	if ply.pickup_count >= upgrade["cost"]:
		ply.pickup_count -= upgrade["cost"]
		upgrade["level"] += 1

		var stat_name = upgrade.get("stat", null)
		var amount = upgrade.get("amount", 0)
		if stat_name:
			if ply.has_variable(stat_name):
				ply.set(stat_name, ply.get(stat_name) + amount)
			else:
				ply.set(stat_name, amount)

		if ply.has_method("_update_ui"):
			ply._update_ui()

		_populate_buttons()


# Menu UI
func open_menu(station_ref: Node) -> void:
	station = station_ref
	visible = true
	_populate_buttons()

func close_menu() -> void:
	visible = false
	_clear_buttons()
