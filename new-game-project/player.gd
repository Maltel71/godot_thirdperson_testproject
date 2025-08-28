extends CharacterBody3D

# Constants
const SPEED = 5.0
const JUMP_VELOCITY = 5.5

# Export variables
@export var sens = 0.2

# On-ready variables to get node references
@onready var pivot = $CameraOrigin
@onready var anim_player = $char_player_bearman1_mesh_v2/AnimationPlayer

# State variables for animation logic
var was_on_floor = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	# If a non-looping animation is already playing (like a landing or interact), don't interrupt it.
	# We can check if the current animation is our jump/inair animations to allow transition.
	if anim_player.is_playing() and (anim_player.current_animation == "bearman1_jump" or anim_player.current_animation == "bearman1_inair"):
		pass
	elif anim_player.is_playing() and not anim_player.current_animation.begins_with("bearman1"):
		# If you add other one-shot animations, this check will prevent them from being overridden.
		# You can adjust this to your needs.
		return
	
	if is_on_floor():
		# Play landing animation once when we first touch the floor
		if not was_on_floor:
			anim_player.play("bearman1_landing")
			return # Exit the function to avoid overriding the landing animation

		# Check if the character is moving
		if velocity.length() > 0.1:
			anim_player.play("bearman1_run")
		else:
			anim_player.play("bearman1_idle")
	else: # Player is in the air
		# Check if the character is moving up (jumping) or down (falling)
		if velocity.y > 0:
			anim_player.play("bearman1_jump")
		else:
			anim_player.play("bearman1_inair")

func _input(event):
	# Handle mouse movement for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	# Handle quit action
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
