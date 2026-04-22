extends CharacterBody3D
@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $visuals/char_player_bearman1_mesh_v3/AnimationPlayer
@onready var visuals: Node3D = $visuals
@onready var melee_collision: CollisionShape3D = $CollisionShape_Melee
var SPEED = 2.5
const JUMP_VELOCITY = 4.5
var walking_speed = 2.8
var running_speed = 5.0
var running = false
var is_locked = false
@export var sens_horizontal = 0.2
@export var sens_vertical = 0.2

# Lunge Variables added for attack
var attack_lunge_speed = 5.0
var attack_deceleration = 10.0

# LOCK & HIDE CURSOR IN THE MIDDLE OF SCREEN ╰┈➤
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#region ATTACK —⟪=====>
# ACTIV/DEACTIV MELEE ATTACK COLLIDER
func activate_melee_attack():
	print("Melee attack activated!")
	melee_collision.disabled = false
	await get_tree().create_timer(0.3).timeout
	melee_collision.disabled = true
	print("Melee attack deactivated!")

# LOOK FOR ATTACK INPUT & PLAY ANIMATION (= ФェФ=)
func handle_attack_input(event):
	if Input.is_action_just_pressed("attack1"):
		if animation_player.current_animation != "bearman1_interact":
			animation_player.play("bearman1_interact")
			is_locked = true
			# Apply a forward lunge by setting the velocity
			var forward_vector = -visuals.global_transform.basis.z.normalized()
			velocity.x = forward_vector.x * attack_lunge_speed
			velocity.z = forward_vector.z * attack_lunge_speed
#endregion
# EVENT INDEX
func _input(event):
	handle_attack_input(event)
	handle_camera_rotation(event)

# CAMERA ROTATION 	⊙ω⊙
func handle_camera_rotation(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
# MOVEMENT
func _physics_process(delta: float) -> void:
	
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Decelerate the lunge when locked in an attack
	if is_locked:
		velocity.x = move_toward(velocity.x, 0, attack_deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, attack_deceleration * delta)
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "bearman1_run":
					animation_player.play("bearman1_run")
			else:
				if animation_player.current_animation != "bearman1_walk":
					animation_player.play("bearman1_walk")
			visuals.look_at(position + direction)
		
		# Only apply horizontal movement when not locked
		if !is_locked:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "bearman1_idle":
				animation_player.play("bearman1_idle")
			
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Always apply physics - this ensures gravity works during attacks
	move_and_slide()
