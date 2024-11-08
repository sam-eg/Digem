extends CharacterBody2D

signal drill_down
signal drill_left
signal drill_right
signal stop_drill
signal out_of_fuel

@onready var animated_sprite = $AnimatedSprite2D
@onready var money_label = $"../UI/PlayingControl/MoneyLabel"
@onready var fuel_bar = $"../UI/PlayingControl/FuelBar"

const MAX_SPEED = 750.0
const ACCELERATION = 500.0 
const FRICTION = 1500.0

const GOLD_VALUE = 25.0

@export var money = 0.0
@export var fuel = 10000

var playing = true

func _physics_process(delta):
	if !playing:
		fuel_bar.value = fuel
		animated_sprite.play("default")
		velocity = get_gravity() * delta

		move_and_slide()

		return

	var input_direction = Vector2()
	
	# Direction
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
		animated_sprite.play("left")
		fuel -= 1
	if Input.is_action_pressed("right"):
		input_direction.x += 1
		animated_sprite.play("right")
		fuel -= 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
		animated_sprite.play("up")
		fuel -= 2
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

func _process(delta):
	if !playing:
		fuel = 0
		return

	if fuel <= 0:
		out_of_fuel.emit()		
		return

	if Input.is_action_pressed("drill_down") or Input.is_action_pressed("drill_left") or Input.is_action_pressed("drill_right"):
		fuel -= 1

	if Input.is_action_just_pressed("drill_down"):
		drill_down.emit()
	if Input.is_action_just_pressed("drill_left"):
		drill_left.emit()
	if Input.is_action_just_pressed("drill_right"):
		drill_right.emit()
	if Input.is_action_just_released("drill_down") or Input.is_action_just_released("drill_left") or Input.is_action_just_released("drill_right"):
		stop_drill.emit()

	money_label.text = "$" + "%.2f" % money
	fuel_bar.value = fuel


func _on_layer_holder_drilled_gold():
	money += GOLD_VALUE


func _on_world_game_over():
	playing = false
