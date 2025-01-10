extends Node

@onready var ray_cast_3d_lowest: RayCast3D = $RayCast3DLowest
@onready var ray_cast_3d_highest: RayCast3D = $RayCast3DHighest
@onready var ray_cast_3d_check: RayCast3D = $RayCast3DCheck
@onready var player: CharacterBody3D = $".."

@export var highestPointToGrab = 2.5
@export var lowestPointToGrab = 0.5
@export var highestPontCheckToPlacePlayer = 2.0
@export var detectionDistance = 1.0
@export var maxPull = 0.1

var distanceGo = 1

var time = 0.0
@export var timeToCheck = 0.5
var timeToCheckSet = 0.0

var timeToMovePlayerSet = -10.0

var setToheight = 0.0

@export var lerpSpeed = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast_3d_lowest.position = Vector3(0,lowestPointToGrab,0)
	ray_cast_3d_highest.position = Vector3(0,highestPointToGrab,0)
	ray_cast_3d_check.position = Vector3(0,highestPointToGrab,-detectionDistance)
	
	ray_cast_3d_lowest.target_position= Vector3(0,0,-detectionDistance)
	ray_cast_3d_highest.target_position = Vector3(0,0,-(detectionDistance+highestPontCheckToPlacePlayer))
	ray_cast_3d_check.target_position = Vector3(0,-(highestPointToGrab-lowestPointToGrab),0)
	setToheight = player.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time = time + delta
	
	if (time >= timeToCheckSet+timeToCheck):
		setToheight = player.position.y
		if (ray_cast_3d_lowest.is_colliding() && !ray_cast_3d_highest.is_colliding() && time >= timeToCheckSet+timeToCheck && Input.is_action_pressed("ui_accept")):
			var condition = true
			var heightCheck = highestPointToGrab-lowestPointToGrab
			ray_cast_3d_check.position = Vector3(0,highestPointToGrab,-detectionDistance)
			timeToCheckSet = time
			while(condition && heightCheck >= maxPull):
				ray_cast_3d_check.target_position = Vector3(0,-heightCheck,0)
				ray_cast_3d_check.force_raycast_update()
				print(heightCheck)
				if(!ray_cast_3d_check.is_colliding()):
					print("Pullup")
					condition = false
					setToheight = highestPointToGrab-heightCheck
					timeToMovePlayerSet = time
				else:
					heightCheck = heightCheck-0.1
	if (time < timeToMovePlayerSet+1/(lerpSpeed)):
		var direction = -player.transform.basis.z*distanceGo
		#-player.transform.basis.z
		player.position = lerp(player.position, Vector3(player.position.x+direction.x,player.position.y+setToheight,player.position.z+direction.z),delta*lerpSpeed)
