class_name SavedTeleportNode
extends Resource

# System will use node paths to find which nodes to connect to each other

@export var node_path: NodePath
@export var area_name: String
@export var sprite_texture_filename: String

@export var overview_position: Vector2

# these arrays' elements should correspond to each other
@export var teleport_connections_node_paths: Array[NodePath]
@export var teleporters: Array # of {position: Vector3, rotation: Vector3, to: NodePath}
