extends TileMap

var players = []

func start():
	var map_area = get_used_rect()
	$Camera2D.limit_left = (map_area.position.x) * 16
	$Camera2D.limit_top = (map_area.position.y) * 16
	$Camera2D.limit_right = (map_area.end.x) * 16
	$Camera2D.limit_bottom = (map_area.end.y) * 16
	
	players = get_tree().get_nodes_in_group("Players")
	var spawns = get_tree().get_nodes_in_group("spawn").slice(0, players.size())
	spawns.shuffle()
	for i in range(0, players.size()):
		players[i].spawn_point = spawns[i].position

func _physics_process(delta):
	if players.size() > 0:
		var camera_position = Vector2.ZERO
		for player in players:
			camera_position += player.position
		$Camera2D.position = (1 / players.size()) * camera_position
