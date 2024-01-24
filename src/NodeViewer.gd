extends Node3D


const teleporter_scene: PackedScene = preload("res://src/Teleporter.tscn")

@onready var mesh: MeshInstance3D = $Bubble
@onready var camera: Camera3D = $Bubble/Camera3D

@onready var indicator_anchor: Node3D = $Bubble/Camera3D/TeleporterIndicatorAnchor
@onready var indicator: Teleporter = $Bubble/Camera3D/TeleporterIndicatorAnchor/TeleporterIndicator

@onready var teleporters: Node3D = $Bubble/Teleporters

@onready var min_indicator_distance: float = 1 + (self.indicator.collision_shape.shape as CylinderShape3D).radius
@onready var max_indicator_distance: float = (mesh.mesh as SphereMesh).radius - (self.indicator.collision_shape.shape as CylinderShape3D).radius

@export var rotation_speed: float = 0.01
@export var indicator_move_speed: float = 0.25


var node: TeleportNode # Get/save all data from/to here


func _ready():
	indicator.position.z = indicator.position.z - min_indicator_distance
	
	Events.teleport_node_enter_requested.connect(_on_teleport_node_enter_requested)
	Events.teleport_node_exit_requested.connect(_on_teleport_node_exit_requested)
	
	Events.connection_entry_select_requested.connect(_on_connection_entry_select_requested)
	Events.connection_entry_delete_requested.connect(_on_connection_entry_delete_requested)


func _process(delta):
	var authoring: TeleportAuthor = self.owner
	
	if not authoring.in_edit_node_mode:
		return
	
	if Input.is_action_pressed("ui_left"):
		camera.rotate_y(rotation_speed)
	if Input.is_action_pressed("ui_right"):
		camera.rotate_y(-rotation_speed)
	if Input.is_action_pressed("ui_up"):
		indicator_anchor.rotate_x(rotation_speed)
	if Input.is_action_pressed("ui_down"):
		indicator_anchor.rotate_x(-rotation_speed)
	
	if not can_add_teleporter():
		indicator.visible = false
	else:
		indicator.visible = true
		if Input.is_action_just_pressed("mouse_scroll_down"):
			if abs(indicator.position.distance_to(camera.position)) > min_indicator_distance:
				indicator.position.z += indicator_move_speed
		if Input.is_action_just_pressed("mouse_scroll_up"):
			if abs(indicator.position.distance_to(camera.position)) < max_indicator_distance:
				indicator.position.z -= indicator_move_speed
		
		if Input.is_action_just_pressed("place_teleporter"):
			add_teleporter()

	indicator.global_rotation.x = 0
	
	# Keep camera rotation level
	camera.rotation.x = 0
	camera.rotation.z = 0


func can_add_teleporter():
	return teleporters.get_child_count() < node.teleport_connections.size()


func add_teleporter():
	var teleporter: Teleporter = teleporter_scene.instantiate()
	
	teleporters.add_child(teleporter)
	teleporter.global_position = indicator.global_position
	teleporter.global_rotation = indicator.global_rotation
	
	node.teleporters.append(teleporter)
	
	Events.teleporter_add_requested.emit(node, teleporter)


func _on_teleport_node_enter_requested(node: TeleportNode):
	self.node = node
	self.mesh.mesh.material.albedo_texture = node.sprite.texture
	
	%"Camera2D".visible = false
	self.visible = true
	
	self.owner.in_edit_node_mode = true


func _on_teleport_node_exit_requested(node: TeleportNode):
	self.node = node
	
	%"Camera2D".visible = true
	self.visible = false
	self.owner.in_edit_node_mode = false


func _on_connection_entry_select_requested(entry: ConnectionEntry):
	# Look at selected entry's assigned teleporter
	if entry.teleporter:
		camera.look_at(entry.teleporter.position)


func _on_connection_entry_delete_requested(entry: ConnectionEntry):
	var teleporter_idx: int = node.teleporters.find(entry.teleporter)
	
	teleporters.remove_child(entry.teleporter)
	entry.teleporter.queue_free()
	
	entry.teleporter = null
	node.teleporters.remove_at(teleporter_idx)
