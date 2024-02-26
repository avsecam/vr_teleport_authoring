class_name SavedTeleportNode
extends Resource

@export var area_name: String
@export var sprite_texture_filename: String

# these arrays' elements should correspond to each other
@export var teleport_connections_names: Array # of SavedTeleportNode names
@export var teleporters: Array # of positions
