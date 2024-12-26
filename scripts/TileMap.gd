extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 64
var height = 64

@onready var player = get_parent().get_node("Player")

var loaded_chunks = []

func _ready():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	altitude.frequency = 0.005

func _process(_delta):
	var player_tile_pos = local_to_map(player.position)
	generate_chunk(player_tile_pos)
	unload_distant_chunks(player_tile_pos)

func generate_chunk(pos: Vector2):
	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(pos.x - (width / 2) + x, pos.y - (height / 2) + y) * 10
			var temp = temperature.get_noise_2d(pos.x - (width / 2) + x, pos.y - (height / 2) + y) * 10
			var alt = altitude.get_noise_2d(pos.x - (width / 2) + x, pos.y - (height / 2) + y) * 10
			var tile_atlas_x = round(3 * (moist + 10) / 20)
			var tile_atlas_y = round(3 * (temp + 10) / 20)
			if alt < 0:
				set_cell(0, Vector2i(pos.x - (width / 2) + x, pos.y - (height / 2) + y), 0, Vector2(3, tile_atlas_y))
			else:
				set_cell(0, Vector2i(pos.x - (width / 2) + x, pos.y - (height / 2) + y), 0, Vector2(tile_atlas_x, tile_atlas_y))
			if Vector2i(pos.x, pos.y) not in loaded_chunks:
				loaded_chunks.append(Vector2i(pos.x, pos.y))

func unload_distant_chunks(player_pos):
	var unload_dist = (width * 2) + 1
	for chunk in loaded_chunks:
		var dist_to_player = dist(chunk, player_pos)
		if dist_to_player > unload_dist:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)

func clear_chunk(pos):
		for x in range(width):
			for y in range(height):
				set_cell(0, Vector2i(pos.x - (width / 2) + x, pos.y - (height / 2) + y), -1, Vector2(-1, -1))

func dist(p1, p2):
	var r = p1 - p2
	return sqrt(r.x ** 2 + r.y ** 2)