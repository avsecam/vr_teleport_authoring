extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@export var panorama_texture_filename: String
@export var area_name: String

@export var teleporters: Array # of Teleporter PackedScenes
@export var rotation_speed: float = 0.01


func _ready():
	mesh_instance.mesh.material.albedo_texture = (load(panorama_texture_filename) as Texture2D)
	
	for teleporter in teleporters:
		mesh_instance.add_child((teleporter as PackedScene).instantiate())


# Add a camera if you will use the following code.
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		$MeshInstance3D/Camera3D.rotate_y(rotation_speed)
	if Input.is_action_pressed("ui_right"):
		$MeshInstance3D/Camera3D.rotate_y(-rotation_speed)
