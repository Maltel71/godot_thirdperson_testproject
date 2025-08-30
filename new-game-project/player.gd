extends CharacterBody3D

# Constants
const SPEED = 5.0
const JUMP_VELOCITY = 5.5

# Export variables
@export var sens = 0.2

# On-ready variables to get node references
@onready var pivot = $CameraOrigin
@onready var anim_tree = $char_player_bearman1_mesh_v3/AnimationTree

# State variables for animation logic
var was_on_floor = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim_tree.active = true # Activate the AnimationTree on start

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

	# Run the animation logic after movement has been calculated
	_animate()

	# Update the floor state for the next frame
	was_on_floor = is_on_floor()

func _animate():
	if is_on_floor():
		# Get the linear speed (horizontal movement only)
		var speed_h = Vector3(velocity.x, 0, velocity.z).length()
		
		# Calculate the blend value based on speed.
		# It's clamped between 0 and 1, where 0 is idle and 1 is run.
		var blend_value = clamp(speed_h / SPEED, 0.0, 1.0)
		
		# Set the blend parameter of the Blend2 node in the AnimationTree.
		# Make sure the node is named "Blend2" in your AnimationTree setup.
		anim_tree.set("parameters/Blend2/blend", blend_value)
	else: # Player is in the air
		# Note: The provided AnimationTree setup only covers idle/walk.
		# Jumping/falling would require an AnimationNodeStateMachine or similar.
		# For now, we do nothing when in the air.
		pass

func _input(event):
	# Handle mouse movement for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	# Handle quit action
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
