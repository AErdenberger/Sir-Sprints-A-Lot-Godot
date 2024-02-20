extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
const SPEED = 150.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 4


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		_animated_sprite.play("Jump")
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		_animated_sprite.play("Run")
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		_animated_sprite.stop()
	
	if not direction and is_on_floor():
		_animated_sprite.play("Idle")

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
