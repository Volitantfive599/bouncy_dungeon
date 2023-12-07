extends Node2D

@export var player_selector_scene : PackedScene

signal player_disconnected
signal selection_finished

var title_screen = true
var start_screen = true
var levels = [
	load("res://levels/level1.tscn")
]
var player_sprites = [
	{ # Blue Ninja
		"icon":	load("res://NinjaAdventure/Actor/Characters/BlueNinja/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/BlueNinja/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/BlueNinja/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/BlueNinja/SeparateAnim/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic3.png")
	},
	{ # Black Ninja Mage
		"icon":	load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/SeparateAnim/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic2.png")
	},
	{ # Tubby Samurai
		"icon":	load("res://NinjaAdventure/Actor/Characters/Samurai/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/Samurai/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/Samurai/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/Samurai/SeparateAnim/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic0.png")
	},
	{ # Frog Guy
		"icon":load("res://NinjaAdventure/Actor/Characters/MaskFrog/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/MaskFrog/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/MaskFrog/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/MaskFrog/Dead14.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic1.png")
	},
	{ # Orange Sorcerer
		"icon":load("res://NinjaAdventure/Actor/Characters/OrangeSorcerer/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/OrangeSorcerer/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/OrangeSorcerer/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/OrangeSorcerer/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic0.png")
	},
	{ # Woman
		"icon":load("res://NinjaAdventure/Actor/Characters/Woman/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/Woman/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/Woman/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/Woman/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic3.png")
	},
	{ # Black Ninja
		"icon":load("res://NinjaAdventure/Actor/Characters/DarkNinja/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/DarkNinja/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/DarkNinja/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/DarkNinja/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic2.png")
	},
	{ # Green Camouflage
		"icon":load("res://NinjaAdventure/Actor/Characters/GreenCamouflage/Faceset.png"),
		"attack":load("res://NinjaAdventure/Actor/Characters/GreenCamouflage/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/GreenCamouflage/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/GreenCamouflage/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic1.png")
	}
]
var ready_players = 0


func _ready():
	get_node("/root/Main/Start_Screen").move_to_character_selector.connect(character_selector_started)
	
	await get_tree().create_timer(0.1).timeout
	Input.joy_connection_changed.connect(players_changed)
	var curr_players = Input.get_connected_joypads()
	for i in curr_players:
		add_player_selector(i)


func players_changed(device_id, connecting):
	if start_screen:
		if connecting:
			add_player_selector(device_id)
		else:
			player_disconnected.emit() # tell level and players to pause
	else:
		if !connecting:
			player_disconnected.emit()


func add_player_selector(device_id):
	var new_player_selector = player_selector_scene.instantiate()
	get_tree().root.add_child(new_player_selector)
	new_player_selector.start(title_screen, device_id, player_sprites)
	new_player_selector.player_ready.connect(check_selection_finished)


func check_selection_finished(player_status):
	ready_players += player_status
	if ready_players == get_tree().get_nodes_in_group("player_selectors").size():
		start_screen = false
		selection_finished.emit()
		load_next_level()
		
		
func character_selector_started():
	title_screen = false


func load_next_level():
	var new_level = levels[randi_range(0, levels.size() - 1)].instantiate()
	get_tree().root.add_child(new_level)
	new_level.start()
