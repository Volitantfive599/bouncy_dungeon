extends TileMap

@export var projectile_scene : PackedScene

var shuriken_colors = [
	load("res://NinjaAdventure/FX/Projectile/ShurikenMagic0.png"),
	load("res://NinjaAdventure/FX/Projectile/ShurikenMagic1.png"),
	load("res://NinjaAdventure/FX/Projectile/ShurikenMagic2.png"),
	load("res://NinjaAdventure/FX/Projectile/ShurikenMagic3.png")
]

func _on_shuriken_timer_timeout():
	var shuriken = projectile_scene.instantiate()
	get_tree().root.add_child(shuriken)
	
	var shuriken_spawn_location = get_node("ShurikenPath/ShurikenSpawnLocation")
	shuriken_spawn_location.progress_ratio = randf()
	var shuriken_position = shuriken_spawn_location.position
	
	var shuriken_direction = shuriken_spawn_location.rotation + PI / 2
	shuriken_direction += randf_range(-PI / 4, PI / 4)
	
	var color = shuriken_colors[randi_range(0, 3)]
	
	shuriken.start(shuriken_position, Vector2(1, 1), color)

