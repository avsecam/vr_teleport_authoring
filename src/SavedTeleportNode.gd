extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@export var panorama_texture: Texture2D
@export var area_name: String

@export var teleporters: Array # of Teleporter PackedScenes
@export var rotation_speed: float = 0.01


func _ready():
	mesh_instance.mesh.material.albedo_texture = panorama_texture
	
	for teleporter in teleporters:
		mesh_instance.add_child((teleporter as PackedScene).instantiate())
