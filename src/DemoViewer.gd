extends Node3D

const teleporter_scene: PackedScene = preload("res://src/Teleporter.tscn")

@onready var mesh: MeshInstance3D = $Bubble
@onready var camera: Camera3D = $Bubble/Camera3D

@onready var teleporters: Node3D = $Bubble/Teleporters

@onready var authoring: TeleportAuthor = %TeleportAuthor

@export var rotation_speed: float = 0.01
@export var indicator_move_speed: float = 0.25

var node: TeleportNode # Get/save all data from/to here

func _ready():
	Events.demo_requested.connect(_on_demo_requested)
	Events.demo_exit_requested.connect(_on_demo_exit_requested)

func _process(_delta):
	# Invert camera to compensate for inverted 360 image
	camera.scale = Vector3(-1, 1, 1)
	
	if Input.is_action_pressed("ui_left"):
		camera.rotation.y -= rotation_speed
	if Input.is_action_pressed("ui_right"):
		camera.rotation.y += rotation_speed

	# Keep camera rotation level
	camera.rotation.x = 0
	camera.rotation.z = 0

func _on_demo_requested(start_node: TeleportNode):
	self.node = start_node
	self.mesh.mesh.material.albedo_texture = start_node.sprite.texture
	self.camera.current = true
	self.camera.rotation.y = start_node.base_rotation
	
	# Load teleporters from TeleportNode
	for i in start_node.teleporters.size():
		teleporters.add_child(start_node.teleporters[i])
	
	self.visible = true

func _on_demo_exit_requested():
	self.node = null
	
	# Clear teleporters
	for i in teleporters.get_child_count():
		var teleporter = teleporters.get_child(0)
		teleporters.remove_child(teleporter)
	
	self.visible = false
