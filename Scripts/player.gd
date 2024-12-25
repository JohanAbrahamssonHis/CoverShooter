extends CharacterBody3D

# Player Obejcts
@onready var head = $Head
@onready var crouching = $Crouching_Coll_Shape
@onready var standing = $Standing_Coll_Shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D

#Speed Vars
var current_speed = 5.0

@export var walking_speed = 5.0
@export var springting_speed = 8.0
@export var crouching_speed = 3.0

#Movement Vars
@export var jump_velocity = 4.5
@export var crouching_depth = -0.5

@export var lerp_speed = 10.0

#Input Vars
@export var mouse_sens = 0.4
var direction = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
	#Mouse Looking
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	
	#Handle Movement States
	
	#Crouching State
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth ,delta*lerp_speed)
		standing.disabled = true;
		crouching.disabled = false;
	#Standing State
	elif !ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		standing.disabled = false;
		crouching.disabled = true;
		#Spriting State
		if Input.is_action_pressed("sprint"):
			current_speed = springting_speed
		#Standard State
		else:
			current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed);
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
