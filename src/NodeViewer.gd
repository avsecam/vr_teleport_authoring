extends Node3D


@onready var mesh: MeshInstance3D = $Bubble
@onready var camera: Camera3D = $Bubble/Camera3D

@onready var indicator_anchor: Node3D = $Bubble/Camera3D/TeleporterIndicatorAnchor
@onready var indicator: StaticBody3D = $Bubble/Camera3D/TeleporterIndicatorAnchor/TeleporterIndicator

@onready var teleporters: Node3D = $Bubble/Teleporters

@export var rotation_speed: float = 0.01
@export var indicator_move_speed: float = 0.25

var node: TeleportNode # Get/save all data from/to here


func _ready():
	Events.teleport_node_enter_requested.connect(_on_teleport_node_enter_requested)
	Events.teleport_node_exit_requested.connect(_on_teleport_node_exit_requested)


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
			indicator.position.z += indicator_move_speed
		if Input.is_action_just_pressed("mouse_scroll_up"):
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
	var teleporter: Teleporter = Teleporter.new()
	
	teleporters.add_child(teleporter)
	teleporter.global_position = indicator.global_position
	teleporter.global_rotation = indicator.global_rotation
	
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
