extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collisionshape = $CollisionShape2D
const SPEED = 150.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 4
var is_crouching = false

var standing_cshape = preload("res://Resources/standing_shape.tres")
var crouching_cshape = preload("res://Resources/crouching_cshape.tres")

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		_animated_sprite.play("Fall")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	velocity.x = direction * SPEED
	
	if direction != 0:
		switch_direction(direction)
		
	if Input.get_action_strength("Crouch"):
		handle_crouch()
	if Input.is_action_just_released("Crouch"):
		handle_standing()

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	
	if health < 1:
		handle_death()
	
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
	_collisionshape.position.y = 10
	
func update_animations(player_direction):
	if is_on_floor():
		if player_direction == 0:
			_animated_sprite.play("Idle")
		else:
			_animated_sprite.play("Run")
	else:
		if velocity.y < 0:
			_animated_sprite.play("Jump")
		elif velocity.y > 0:
			_animated_sprite.play("Fall")

func switch_direction(player_direction):
	_animated_sprite.flip_h = (player_direction == -1)
