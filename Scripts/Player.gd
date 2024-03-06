extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collisionshape = $CollisionShape2D
const SPEED = 150.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 4
var facing_right = true
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
	if direction != 0:
		velocity.x = direction * SPEED
		if (direction > 0 and not facing_right) or (direction < 0 and facing_right):
			_animated_sprite.flip_h = facing_right
			facing_right = !facing_right
			if is_crouching:
				_animated_sprite.play("CrouchWalk")
			else:
				_animated_sprite.play("Run")
		else:
			if is_crouching:
				_animated_sprite.play("CrouchWalk")
			else:
				_animated_sprite.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		_animated_sprite.stop()
		
	if Input.get_action_strength("Crouch"):
		handle_crouch()
	if Input.is_action_just_released("Crouch"):
		handle_standing()
		
	
	if velocity == Vector2.ZERO and is_on_floor():
		_animated_sprite.play("Idle")

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		if(_animated_sprite.is_playing()):
			_animated_sprite.stop()
		_animated_sprite.play("Jump")
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	
	if health < 1:
		handle_death()
	
	if global_position.y > 500:
		game_over()
	
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
