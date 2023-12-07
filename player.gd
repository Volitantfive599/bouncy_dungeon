extends RigidBody2D

@export var projectile_scene : PackedScene

signal got_hit

var player_sprite
var player_num 
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

func start(player_id, sprite):
	player_sprite = sprite
	player_num = str(player_id)
	hide()
	freeze = true

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
				pass
				# state = states.DASH
			elif input != Vector2.ZERO:
				state = states.RUN

	match state:
		states.DEAD:
			$Label.text = "dead"
			set_physics_process(false)
			$Sprite2D.texture = player_sprite["death"]
			$AnimationPlayer.play("death")
			
		states.IDLE:
			$Label.text = "idle"
			$Sprite2D.texture = player_sprite["walk"]
			$AnimationPlayer.play("walk" + dir)
			$AnimationPlayer.stop()
			
		states.RUN:
			$Label.text = "run"
			$Sprite2D.texture = player_sprite["walk"]
			$AnimationPlayer.play("walk" + dir)
			apply_force(input * run_speed)
			
			state = states.IDLE
			
		states.ATTACK:
			$Label.text = "attack"
			$Sprite2D.texture = player_sprite["attack"]
			dir = attackDir
			$AnimationPlayer.play("attack" + attackDir)
			
			if can_attack:
				can_attack = false
				attacks_left -= 1
				var new_projectile = projectile_scene.instantiate()
				get_tree().root.add_child(new_projectile)
				new_projectile.start(position + (16 * attackInput), attackInput.normalized(), player_sprite["shuriken"])
			
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
