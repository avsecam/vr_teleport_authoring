class_name Teleporter
extends StaticBody3D


@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $CollisionShape3D/MeshInstance3D


var teleport_location: TeleportNode

@export_category("On save")
@export var teleport_location_resource_path: String
