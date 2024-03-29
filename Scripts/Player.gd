extends CharacterBody2D

signal healthChanged

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collisionshape = $CollisionShape2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_crouching = false
var standing_cshape = preload("res://Resources/standing_shape.tres")
var crouching_cshape = preload("res://Resources/crouching_cshape.tres")

@export var max_health = 4
var cur_health = max_health
var isHurt = false

var score : int = 0

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if is_crouching:
		velocity.x = (direction * SPEED) /2
	else:
		velocity.x = direction * SPEED
	
	if direction != 0:
		switch_direction(direction)
		
	if Input.is_action_just_pressed("Crouch"):
		handle_crouch()
	if Input.is_action_just_released("Crouch"):
		handle_standing()

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	
	if global_position.y > 500:
		game_over()
	
	update_animations(direction)
	
func game_over():
	get_tree().reload_current_scene()
	
func handle_death():
	_animated_sprite.play("Death")
	game_over()
	
func handle_crouch():
	if is_crouching:
		return
	is_crouching = true
	_collisionshape.shape = crouching_cshape
	_collisionshape.position.x = -2
	_collisionshape.position.y = 13

func handle_standing():
	if not is_crouching:
		return
	is_crouching = false
	_collisionshape.shape = standing_cshape
	_collisionshape.position.x = -2
	_collisionshape.position.y = 11.25
	
func update_animations(player_direction):
	if is_on_floor():
		if player_direction == 0:
			if is_crouching:
				_animated_sprite.play("Crouch")
			else:
				_animated_sprite.play("Idle")
		else:
			if is_crouching:
				_animated_sprite.play("CrouchWalk")
			else:
				_animated_sprite.play("Run")
	else:
		if velocity.y < 0:
			_animated_sprite.play("Jump")
		elif velocity.y > 0:
			_animated_sprite.play("Fall")

func switch_direction(player_direction):
	_animated_sprite.flip_h = (player_direction == -1)
	if _animated_sprite.flip_h:
		_animated_sprite.position.x = player_direction * 4

func add_score(amount):
	score += amount
	

func _on_hurt_box_area_entered(area):
	if area.name == "hitBox":
		cur_health -= 1
		if cur_health < 0:
			cur_health = max_health
		
		healthChanged.emit(cur_health)
		
