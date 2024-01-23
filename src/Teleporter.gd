class_name Teleporter
extends StaticBody3D


@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $CollisionShape3D/MeshInstance3D


var teleport_location: TeleportNode
