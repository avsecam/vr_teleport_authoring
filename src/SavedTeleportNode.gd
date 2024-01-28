extends Node3D


@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@export var panorama_texture: Texture2D
@export var area_name: String

var teleporters: Array # of Teleporters


func _ready():
	mesh_instance.mesh.material.albedo_texture = panorama_texture
