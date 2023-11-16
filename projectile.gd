extends RigidBody2D

var speed = 7000
var dir
var bounces = 5
var fade_out = false

func start(pos, direction):
	position = pos
	dir = direction
	apply_force(dir * speed)
	$AnimationPlayer.play("magicspin")

func _on_body_entered(body):
	bounces -= 1
	if bounces == 1:
		$AnimationPlayer.play("normalspin")
	if bounces == 0:
		$AnimationPlayer.stop()
		set_deferred("freeze", true)
		fade_out = true

func _physics_process(delta):
	if fade_out:
		$Sprite2D.modulate *= 0.95
		await get_tree().create_timer(1).timeout
		free()
