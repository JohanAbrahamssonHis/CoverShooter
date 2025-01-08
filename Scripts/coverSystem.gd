extends Node

class_name Cover

@onready var ray_cast_3d_top_right: RayCast3D = $RayCast3DTopRight
@onready var ray_cast_3d_top_left: RayCast3D = $RayCast3DTopLeft
@onready var ray_cast_3d_bottom_right: RayCast3D = $RayCast3DBottomRight
@onready var ray_cast_3d_bottom_left: RayCast3D = $RayCast3DBottomLeft

@export var width = 1.0
@export var height = 2.0
@export var groundHeight = 0.1
@export var length = 1
@export var frontOffset = 0.4
@export var crouchingHeight = 0.5

@export var isCrouching = false

var check = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast_3d_top_right.position = Vector3(width/2,height,-frontOffset)
	ray_cast_3d_top_left.position = Vector3(-width/2,height,-frontOffset)
	ray_cast_3d_bottom_right.position = Vector3(width/2,groundHeight,-frontOffset)
	ray_cast_3d_bottom_left.position = Vector3(-width/2,groundHeight,-frontOffset)
	
	
	ray_cast_3d_top_right.target_position = Vector3(0,0,-length)
	ray_cast_3d_top_left.target_position = Vector3(0,0,-length)
	ray_cast_3d_bottom_right.target_position = Vector3(0,0,-length)
	ray_cast_3d_bottom_left.target_position = Vector3(0,0,-length)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(!isCrouching):
		ray_cast_3d_top_right.position = Vector3(width/2,height,-frontOffset)
		ray_cast_3d_top_left.position = Vector3(-width/2,height,-frontOffset)
	elif(isCrouching):
		ray_cast_3d_top_right.position = Vector3(width/2,crouchingHeight,-frontOffset)
		ray_cast_3d_top_left.position = Vector3(-width/2,crouchingHeight,-frontOffset)
	if(ray_cast_3d_top_right.is_colliding() && 
	ray_cast_3d_top_left.is_colliding() && 
	ray_cast_3d_bottom_right.is_colliding() && 
	ray_cast_3d_bottom_left.is_colliding()):
		check += 1
		print(check)
