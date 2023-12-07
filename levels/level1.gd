extends TileMap

var map_distance
var max_zoom = Vector2(5, 5)
var min_zoom = 0.8

func start():
	var map_area = get_used_rect()
	$Camera2D.limit_left = (map_area.position.x) * 16
	$Camera2D.limit_top = (map_area.position.y) * 16
	$Camera2D.limit_right = (map_area.end.x) * 16
	$Camera2D.limit_bottom = (map_area.end.y) * 16
	map_distance = sqrt((map_area.end.x - map_area.position.x) ** 2 + (map_area.end.y - map_area.position.y) ** 2) * 16
	
	var players = get_tree().get_nodes_in_group("Players")
	for player in players:
		player.show()
		player.freeze = false

func _physics_process(delta):
	var players = get_tree().get_nodes_in_group("Players")
	var camera_position = Vector2.ZERO
	for player in players:
		camera_position += player.position
	$Camera2D.position = (1 / players.size()) * camera_position
