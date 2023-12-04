extends RigidBody2D

var speed = 7000
var dir
var bounces = 5
var fade_out = false
var lethal = false

func start(pos, direction, shuriken_color):
	position = pos
	dir = direction
	$Sprite2D.texture = shuriken_color
	apply_force(dir * speed)
	$AnimationPlayer.play("magicspin")
	await get_tree().create_timer(0.05).timeout
	lethal = true

func _on_body_entered(body):
	if body.is_in_group("Players") and lethal:
		body.hurt(1)
	
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
		queue_free()
