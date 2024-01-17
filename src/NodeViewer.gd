extends Node3D


@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $"MeshInstance3D/Camera3D"

@export var rotation_speed: float = 0.01

var node: TeleportNode


func _ready():
	Events.teleport_node_enter_requested.connect(_on_teleport_node_enter_requested)
	Events.teleport_node_exit_requested.connect(_on_teleport_node_exit_requested)


func _process(delta):
	if %"TeleportNodes".in_edit_node_mode:
		if Input.is_action_pressed("ui_left"):
			camera.rotate_y(rotation_speed)
		if Input.is_action_pressed("ui_right"):
			camera.rotate_y(-rotation_speed)

#		if Input.is_action_just_pressed("mouse_scroll_down"):
#			self.zoom = Vector2(self.zoom.x - zoom_speed, self.zoom.y - zoom_speed)
#		if Input.is_action_just_pressed("mouse_scroll_up"):
#			self.zoom = Vector2(self.zoom.x + zoom_speed, self.zoom.y + zoom_speed)


func _on_teleport_node_enter_requested(node: TeleportNode):
	self.node = node
	self.mesh.mesh.material.albedo_texture = node.sprite.texture
	
	%"Camera2D".visible = false
	self.visible = true
	%"TeleportNodes".in_edit_node_mode = true


func _on_teleport_node_exit_requested(node: TeleportNode):
	self.node = node
	%"Camera2D".visible = true
	self.visible = false
	%"TeleportNodes".in_edit_node_mode = false
