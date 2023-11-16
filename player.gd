extends RigidBody2D
@export var projectile_scene : PackedScene

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
var can_attack = true
enum states {IDLE, RUN, ATTACK, DEAD, HURT}
var state = states.IDLE

func _physics_process(delta):
	choose_action()


func choose_action():
	$Label.text = dir
	
	if Input.is_action_pressed("attack") and state != states.ATTACK:
		state = states.ATTACK
		attackInput = Vector2.ZERO
		attackDir = dir
		for direction in inputs.keys():
			if Input.is_action_pressed("attack" + direction):
				attackDir = direction
				attackInput += inputs[direction]
		if attackInput == Vector2.ZERO:
			attackInput = input
			if attackInput == Vector2.ZERO:
				attackInput = inputs[dir]
			
	elif state != states.ATTACK:
		input = Vector2.ZERO
		for direction in inputs.keys():
			if Input.is_action_pressed(direction):
				dir = direction
				input += inputs[direction]
		input = Input.get_vector("left", "right", "up", "down")
		if input != Vector2.ZERO:
			state = states.RUN

	match state:
		states.DEAD:
			pass
			
		states.IDLE:
			# $Label.text = "idle"
			$AnimationPlayer.stop()
			
		states.RUN:
			# $Label.text = "walk" + dir
			$AnimationPlayer.play("walk" + dir)
			apply_force(input * run_speed)
			
			state = states.IDLE
			
		states.ATTACK:		
			dir = attackDir
			# $Label.text = "attack" + attackDir
			$AnimationPlayer.play("attack" + attackDir)
			
			if can_attack:
				can_attack = false
				var new_projectile = projectile_scene.instantiate()
				get_tree().root.add_child(new_projectile)
				new_projectile.start(position + (16 * attackInput), attackInput.normalized())
			
				await get_tree().create_timer(0.5).timeout
				can_attack = true
				$AnimationPlayer.play("walk" + dir)
				state = states.IDLE
			
		states.HURT:
			pass
