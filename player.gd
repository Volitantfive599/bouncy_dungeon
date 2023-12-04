extends RigidBody2D
@export var projectile_scene : PackedScene
@export var player_num : String

signal got_hit

var player_sprites = {
	"0":{ # Frog Guy
		"attack":load("res://NinjaAdventure/Actor/Characters/MaskFrog/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/MaskFrog/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/MaskFrog/Dead14.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic1.png")
	},
	"1":{ # Black Ninja Mage
		"attack":load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/BlackNinjaMage/SeparateAnim/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic2.png")
	},
	"2":{ # Blue Ninja
		"attack":load("res://NinjaAdventure/Actor/Characters/BlueNinja/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/BlueNinja/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/BlueNinja/SeparateAnim/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic3.png")
	},
	"3":{ # Tubby Samurai
		"attack":load("res://NinjaAdventure/Actor/Characters/Samurai/SeparateAnim/Attack.png"),
		"walk":load("res://NinjaAdventure/Actor/Characters/Samurai/SeparateAnim/Walk.png"),
		"death":load("res://NinjaAdventure/Actor/Characters/Samurai/SeparateAnim/Dead.png"),
		"shuriken":load("res://NinjaAdventure/FX/Projectile/ShurikenMagic0.png")
	}
}
var dir = "down"
var attackDir
var inputs = {
	"down":Vector2.DOWN,
	"up":Vector2.UP,
	"right":Vector2.RIGHT,
	"left":Vector2.LEFT
}
var input = Vector2.ZERO
var attackInput = Vector2.ZERO
var run_speed = 500
var locked = false
var can_attack = true
var attacks_left = 3
var dash = false
var health = 3
enum states {IDLE, RUN, ATTACK, DEAD, HURT, DASH}
var state = states.IDLE

func _integrate_forces(state):
	pass

func _physics_process(delta):
	choose_action()

func choose_action():
	if !locked:
		if Input.is_action_pressed("attack" + player_num) and !locked and attacks_left > 0:
			state = states.ATTACK
			locked = true
			attackInput = Vector2.ZERO
			attackDir = dir
			for direction in inputs.keys():
				if Input.is_action_pressed("attack" + direction + player_num):
					attackDir = direction
			attackInput = Input.get_vector("attackleft" + player_num, "attackright" + player_num, "attackup" + player_num, "attackdown" + player_num)
			if attackInput == Vector2.ZERO:
				attackInput = input
				if attackInput == Vector2.ZERO:
					attackInput = inputs[dir]
		
		else:
			for direction in inputs.keys():
				if Input.is_action_pressed(direction + player_num):
					dir = direction
			input = Input.get_vector("left" + player_num, "right" + player_num, "up" + player_num, "down" + player_num)
			if Input.is_action_pressed("dash" + player_num) and !locked:
				state = states.DASH
			elif input != Vector2.ZERO:
				state = states.RUN

	match state:
		states.DEAD:
			$Label.text = "dead"
			set_physics_process(false)
			$Sprite2D.texture = player_sprites[player_num]["death"]
			$AnimationPlayer.play("death")
			
		states.IDLE:
			$Label.text = "idle"
			$Sprite2D.texture = player_sprites[player_num]["walk"]
			$AnimationPlayer.play("walk" + dir)
			$AnimationPlayer.stop()
			
		states.RUN:
			$Label.text = "run"
			$Sprite2D.texture = player_sprites[player_num]["walk"]
			$AnimationPlayer.play("walk" + dir)
			apply_force(input * run_speed)
			
			state = states.IDLE
			
		states.ATTACK:
			$Label.text = "attack"
			$Sprite2D.texture = player_sprites[player_num]["attack"]
			dir = attackDir
			$AnimationPlayer.play("attack" + attackDir)
			
			if can_attack:
				can_attack = false
				attacks_left -= 1
				var new_projectile = projectile_scene.instantiate()
				get_tree().root.add_child(new_projectile)
				new_projectile.start(position + (16 * attackInput), attackInput.normalized(), player_sprites[player_num]["shuriken"])
			
				await get_tree().create_timer(0.5).timeout
				can_attack = true
				state = states.IDLE
				locked = false
			
		states.HURT:
			$Label.text = "hurt"
		
		states.DASH:
			# Currently disabled
			$AnimationPlayer.play("smoke")
			locked = true
			await get_tree().create_timer(0.6).timeout
			$Effects.hide()
			locked = false
			state = states.IDLE


func _on_attack_timer_timeout():
	if attacks_left < 3:
		attacks_left += 1


func hurt(amount):
	if health > 1:
		$Hurt_Label.text = "Ouch"
		health -= amount
		got_hit.emit(health)
		var prev_state = state
		state = states.HURT
		await get_tree().create_timer(0.2).timeout
		$Hurt_Label.text = ""
		state = prev_state
	else:
		locked = true
		health -= amount
		got_hit.emit(health)
		state = states.DEAD
