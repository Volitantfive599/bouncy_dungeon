extends TileMap

@export var projectile_scene : PackedScene

signal move_to_character_selector

var title_screen = true
var shuriken_colors


func _ready():
	$StartScreen.show()
	$CharacterSelect.hide()
	shuriken_colors = get_parent().player_sprites
	

func _on_shuriken_timer_timeout():
	var shuriken = projectile_scene.instantiate()
	get_tree().root.add_child(shuriken)
	
	var shuriken_spawn_location = get_node("ShurikenPath/ShurikenSpawnLocation")
	shuriken_spawn_location.progress_ratio = randf()
	var shuriken_position = shuriken_spawn_location.position
	
	var shuriken_direction = shuriken_spawn_location.rotation + PI / 2
	shuriken_direction += randf_range(-PI / 4, PI / 4)
	
	var color = shuriken_colors[randi_range(0, shuriken_colors.size() - 1)]["shuriken"]
	
	shuriken.start(shuriken_position, Vector2(1, 1), color)


func _on_start_button_pressed():
	title_screen = false
	$AcceptMusic.play()
	$ShurikenTimer.stop()
	$StartScreen.hide()
	$CharacterSelect.show()
	move_to_character_selector.emit()
	
	
func _physics_process(delta):
	if title_screen and Input.is_action_pressed("dash0"):
		await get_tree().create_timer(0.016).timeout
		_on_start_button_pressed()


func _on_main_selection_finished():
	queue_free()
