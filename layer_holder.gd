extends Node2D

@onready var land = $Land
@onready var background = $Background
@onready var player = $"../Player"

const LAND_SOURCE_ID = 0
const DIRT_TILE = Vector2i(3, 0)
const STONE_TILE = Vector2i(2, 1)
const GOLD_TILE = Vector2i(4, 0)
const AIR_TILE = Vector2i(0, 0)

const BACKGROUND_SKY_SOURCE_ID = 0
const BACKGROUND_GROUND_SOURCE_ID = 1
const BACKGROUND_TILE = Vector2i(0, 0)

const TILE_SIZE = 64
const CHUNK_SIZE = 32

var landMap = {} # Dictionary aka map. GDScript, eh?

func _process(_delta):
	load_chunk(player.position)

func load_chunk(player_position):
	land.clear()
	background.clear()
	
	var tile_pos = land.local_to_map(player_position)
	for tileX in range(CHUNK_SIZE):
		for tileY in range(CHUNK_SIZE):
			var current_tile_position = Vector2i(tileX + tile_pos.x - CHUNK_SIZE / 2, tileY + tile_pos.y - CHUNK_SIZE / 2)

			if current_tile_position.y < 0:
				if background.get_cell_source_id(current_tile_position) == -1:
					background.set_cell(current_tile_position, BACKGROUND_SKY_SOURCE_ID, BACKGROUND_TILE)
			else:
				if background.get_cell_source_id(current_tile_position) == -1:
					background.set_cell(current_tile_position, BACKGROUND_GROUND_SOURCE_ID, BACKGROUND_TILE)

			var tile_type
			if landMap.has(current_tile_position): # Check if we already generated a tile for this position
				tile_type = landMap[current_tile_position]
			elif land.get_cell_source_id(current_tile_position) == -1 && current_tile_position.y >= 0:
				var tile_type_rand = randi() % 20
				
				match tile_type_rand: # This is GDScript's switch statement
					0:
						tile_type = GOLD_TILE
					1, 2, 3:
						tile_type = STONE_TILE
					4, 5:
						tile_type = AIR_TILE
					_: # default
						tile_type = DIRT_TILE
			# If we have a new tile type and the tile is empty
			if tile_type != null and land.get_cell_source_id(current_tile_position) == -1:
				land.set_cell(current_tile_position, LAND_SOURCE_ID, tile_type)
				landMap[current_tile_position] = tile_type
