extends Node2D

signal drilled_gold

@onready var land = $Land
@onready var background = $Background
@onready var player = $"../Player"
@onready var drill_timer = $"../DrillTimer"
@onready var drill_particles = $"../DrillParticles"

const LAND_SOURCE_ID = 0
const DIRT_TILE = Vector2i(3, 0)
const STONE_TILE = Vector2i(2, 1)
const GOLD_TILE = Vector2i(4, 0)
const AIR_TILE = Vector2i(0, 0)

const GAS_SOURCE_ID = 1
const GAS_TILE = Vector2i(0, 0)
const GAS_LOC = Vector2i(0, -1)

const DIRT_DRILL_TIME = 1.0
const STONE_DRILL_TIME = 2.0
const GOLD_DRILL_TIME = 1.5

const DIRECTION_LEFT = "left"
const DIRECTION_RIGHT = "right"
const DIRECTION_DOWN = "down"

const BACKGROUND_SKY_SOURCE_ID = 0
const BACKGROUND_GROUND_SOURCE_ID = 1
const BACKGROUND_TILE = Vector2i(0, 0)

const TILE_SIZE = 64
const CHUNK_SIZE = 32

var land_map = {} # Dictionary aka map. GDScript, eh?

var drilling_location
var drilled_tile
var drill_direction
var is_drilling_tile_gold

func _process(_delta):
	var tile_pos = land.local_to_map(player.position)
	if tile_pos == GAS_LOC:
		add_fuel()
		
	if drilled_tile != null:
		player.fuel -= 1
	
	load_chunk(tile_pos)

func load_chunk(tile_pos):
	land.clear()
	background.clear()
	
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
			if current_tile_position == GAS_LOC:
				land.set_cell(current_tile_position, GAS_SOURCE_ID, GAS_TILE)
			elif land_map.has(current_tile_position): # Check if we already generated a tile for this position
				tile_type = land_map[current_tile_position]
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
				land_map[current_tile_position] = tile_type

func add_fuel():
	if player.money >= 0.01 and player.fuel <= 9990:
		player.money -= 0.01
		player.fuel += 10
	elif player.money >= 0.01 and player.fuel < 10000:
		player.money -= 0.01
		player.fuel = 10000

func _on_player_drill_down():
	drill(DIRECTION_DOWN)


func _on_player_drill_left():
	drill(DIRECTION_LEFT)


func _on_player_drill_right():
	drill(DIRECTION_RIGHT)


func _on_player_stop_drill():
	reset_drilling()


func drill(direction):
	var current_tile = land.local_to_map(player.get_global_position())
	var drill_tile_position
	match direction:
		DIRECTION_DOWN:
			drill_tile_position = current_tile + Vector2i.DOWN
		DIRECTION_LEFT:
			drill_tile_position = current_tile + Vector2i.LEFT
		DIRECTION_RIGHT:
			drill_tile_position = current_tile + Vector2i.RIGHT
		_:
			pass

	if drill_tile_position != null:
		var tile_type = land.get_cell_atlas_coords(drill_tile_position)
		if tile_type != AIR_TILE and tile_type != Vector2i(-1, -1):
			drilling_location = current_tile
			drilled_tile = drill_tile_position
			drill_direction = direction
			is_drilling_tile_gold = tile_type == GOLD_TILE
			drill_particles.emitting = true
			drill_particles.position = land.map_to_local(drilled_tile)

		if tile_type == DIRT_TILE:
			drill_timer.start(DIRT_DRILL_TIME)
		if tile_type == STONE_TILE:
			drill_timer.start(STONE_DRILL_TIME)
		if tile_type == GOLD_TILE:
			drill_timer.start(GOLD_DRILL_TIME)


func _on_drill_timer_timeout():
	var current_tile = land.local_to_map(player.get_global_position())
	if current_tile != drilling_location: # Player moved after starting drill
		reset_drilling()
	
	if drilled_tile != null and drilled_tile != null and drill_direction != null:
		land.set_cell(drilled_tile, LAND_SOURCE_ID, AIR_TILE)
		land_map[drilled_tile] = AIR_TILE
		if is_drilling_tile_gold:
			emit_signal("drilled_gold")
		reset_drilling()


func reset_drilling():
	drilling_location = null
	drilled_tile = null
	drill_direction = null
	is_drilling_tile_gold = false
	drill_particles.emitting = false
