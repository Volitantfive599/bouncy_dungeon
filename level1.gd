extends TileMap

var map_distance
var max_zoom = Vector2(5, 5)
var min_zoom = 0.8

func _ready():
	var map_area = get_used_rect()
	$Camera2D.limit_left = (map_area.position.x) * 16
	$Camera2D.limit_top = (map_area.position.y) * 16
	$Camera2D.limit_right = (map_area.end.x) * 16
	$Camera2D.limit_bottom = (map_area.end.y) * 16
	map_distance = sqrt((map_area.end.x - map_area.position.x) ** 2 + (map_area.end.y - map_area.position.y) ** 2) * 16

func _physics_process(delta):
	$Camera2D.position = 0.5 * ($Player0.position + $Player1.position)
	$Camera2D.zoom = max_zoom * max(min_zoom, (1 - ($Player0.position.distance_to($Player1.position) / map_distance)))
