extends CharacterBody3D

var Cover = preload("res://Scripts/coverSystem.gd")

# Player States
enum PlayerState{
	Still,
	Walking,
	Running,
	Crouching,
	Aiming
}
@export var currentPlayerState = PlayerState.Still;

@onready var cover: Cover = $Cover



@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var pistol_1: Control = $CanvasLayer/pistol1
@export var cameraBobFrequencyX = 4
@export var cameraBobFrequencyY = 8
@export var cameraBobAmplitudeX = 4
@export var cameraBobAmplitudeY = 2
@export var cameraBounce = 45
var pistol_1SavePos

#ADS variables
@export var FOVZoom = 30.0
@export var ScaleZoom = 2.0
@export var SpriteDownPull = 300.0
@onready var pistol_animation = $CanvasLayer/pistol1/pistol_sprite
var playOnce = false

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

var time = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pistol_1SavePos = pistol_1.position

func _input(event: InputEvent):
	#Mouse Looking
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	time += delta
	
	cover.isCrouching = currentPlayerState == PlayerState.Crouching
	
	returnToBase(delta)
	
	if currentPlayerState!=PlayerState.Still:
		screenMove(cameraBobFrequencyX,cameraBobAmplitudeX,cameraBobFrequencyY,cameraBobAmplitudeY, delta)
	#Handle Movement States
	
	if Input.is_action_pressed("ADS"):
		pistol_1.scale = lerp(pistol_1.scale, Vector2(ScaleZoom,ScaleZoom), delta*lerp_speed)
		pistol_1.position = lerp(pistol_1.position, pistol_1.position+Vector2(0,SpriteDownPull), delta*lerp_speed)
		camera_3d.fov = lerp(camera_3d.fov, FOVZoom, delta*lerp_speed)
		if(!playOnce):
			playOnce = true
			pistol_animation.play("ads",1,false)
	else:
		pistol_1.scale = lerp(pistol_1.scale, Vector2(1,1), delta*lerp_speed)
		camera_3d.fov = lerp(camera_3d.fov, 75.0, delta*lerp_speed)
		if(playOnce):
			pistol_animation.play_backwards("ads")
		playOnce = false
	
	#Crouching State
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth ,delta*lerp_speed)
		standing.disabled = true;
		crouching.disabled = false;
		currentPlayerState = PlayerState.Crouching;
	#Standing State
	elif !ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		standing.disabled = false;
		crouching.disabled = true;
		currentPlayerState = PlayerState.Still;
		#Spriting State
		if Input.is_action_pressed("sprint"):
			current_speed = springting_speed
			currentPlayerState = PlayerState.Running;
		#Standard State
		else:
			current_speed = walking_speed
			currentPlayerState = PlayerState.Walking;
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jumpMove(delta)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if input_dir==Vector2.ZERO:
		currentPlayerState = PlayerState.Still
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed);
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


func screenMove(param1T1, param2T1,param1T2, param2T2, delta):
	pistol_1.position += lerp(Vector2(sin(param1T1*time)*param2T1,-abs(sin(param1T2*time)*param2T2)),Vector2.ZERO,delta*lerp_speed)
	
func returnToBase(delta):
	pistol_1.position = lerp(pistol_1.position,pistol_1SavePos,delta*lerp_speed)
	
func jumpMove(delta):
	pistol_1.position = lerp(pistol_1.position,pistol_1SavePos + Vector2(0,cameraBounce),delta*lerp_speed)
