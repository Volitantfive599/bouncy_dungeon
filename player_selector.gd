extends MarginContainer

@export var player_scene : PackedScene

signal player_ready

var on_title_screen = true
var locked = false
var player_id
var player_icons
var current_icon = 0
var icon_spawns= [
	Vector2(150 - (size.x * scale.x / 2), 116 - (size.y * scale.y / 2)),
	Vector2(198 - (size.x * scale.x / 2), 116 - (size.y * scale.y / 2)),
	Vector2(246 - (size.x * scale.x / 2), 116 - (size.y * scale.y / 2)),
	Vector2(294 - (size.x * scale.x / 2), 116 - (size.y * scale.y / 2)),
]

func start(title_screen, id, icons):
	on_title_screen = title_screen
	if on_title_screen:
		hide()
	player_id = id
	player_icons = icons
	$MarginContainer/TextureRect.texture = player_icons[current_icon]["icon"]
	position = icon_spawns[player_id]
	get_node("/root/Main").selection_finished.connect(create_player)
	get_node("/root/Main").player_disconnected.connect(player_selector_disconnected)
	get_node("/root/Main/Start_Screen").move_to_character_selector.connect(character_selector_started)
		

func _process(delta):
	if !locked:
		if Input.is_action_just_pressed("left" + str(player_id)):
			change_sprite(-1)
		elif Input.is_action_just_pressed("right" + str(player_id)):
			change_sprite(1)
		elif Input.is_action_just_pressed("dash" + str(player_id)):
			if !on_title_screen:
				locked = true
				player_ready.emit(1)
	else:
		if Input.is_action_just_pressed("dash" + str(player_id)):
			locked = false
			player_ready.emit(-1)


func change_sprite(change):
	current_icon += change
	if current_icon == player_icons.size():
		current_icon = 0
	elif current_icon < 0:
		current_icon = player_icons.size() - 1
	$MarginContainer/TextureRect.texture = player_icons[current_icon]["icon"]


func create_player():
	var new_player = player_scene.instantiate()
	get_tree().root.add_child(new_player)
	new_player.start(player_id, player_icons[current_icon])
	queue_free()


func player_selector_disconnected():
	queue_free()


func character_selector_started():
	on_title_screen = false
	show()
