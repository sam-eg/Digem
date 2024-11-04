extends CharacterBody2D

signal drill_down
signal drill_left
signal drill_right
signal stop_drill

@onready var animated_sprite = $AnimatedSprite2D

const MAX_SPEED = 750.0
const ACCELERATION = 500.0 
const FRICTION = 1500.0 

func _physics_process(delta):
	var input_direction = Vector2()
	
	# Direction
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
		animated_sprite.play("left")
	if Input.is_action_pressed("right"):
		input_direction.x += 1
		animated_sprite.play("right")
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
		animated_sprite.play("up")
	if Input.is_action_pressed("up") and Input.is_action_pressed("left"):
		animated_sprite.play("up_left")
	if Input.is_action_pressed("up") and Input.is_action_pressed("right"):
		animated_sprite.play("up_right")
	if Input.is_action_pressed("up") and Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		animated_sprite.play("up_left_right")
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right") and !Input.is_action_pressed("up"):
		animated_sprite.play("default")
	
	input_direction = input_direction.normalized()
	
	if input_direction == Vector2.ZERO: #Friction
		if velocity.x < 0:
			if velocity.x < -1 * FRICTION * delta:
				velocity.x += FRICTION * delta
			else:
				velocity.x = 0 # deal with small drift amounts
		elif velocity.x > 0:
			if velocity.x > FRICTION * delta:
				velocity.x -= FRICTION * delta
			else:
				velocity.x = 0 # deal with small drift amounts
	else: # Movement
		velocity += input_direction * ACCELERATION * delta
	
	if not is_on_floor() and input_direction.y == 0: # Gravity
		velocity += get_gravity() * delta

	if velocity.length() > MAX_SPEED: # Max speed
		velocity = MAX_SPEED * (velocity.normalized())

	move_and_slide()
	
	for i in get_slide_collision_count(): # Tile collision WIP
		var collision = get_slide_collision(i)
		if collision.get_collider() is TileMapLayer:
			var land = collision.get_collider() as TileMapLayer

			var own_tile = land.local_to_map(get_global_position())
			var collide_tile = land.local_to_map(collision.get_position())
			#print("I collided with ", land.name, " at ", collide_tile)
		else:
			pass
			#print ("Collided with ", collision.get_collider().name)

func _process(delta):
	if Input.is_action_just_pressed("drill_down"):
		drill_down.emit()
	if Input.is_action_just_pressed("drill_left"):
		drill_left.emit()
	if Input.is_action_just_pressed("drill_right"):
		drill_right.emit()
	if Input.is_action_just_released("drill_down") or Input.is_action_just_released("drill_left") or Input.is_action_just_released("drill_right"):
		stop_drill.emit()
