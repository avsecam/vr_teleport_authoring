extends Node3D


func _ready():
	Events.teleport_node_enter_requested.connect(_on_teleport_node_enter_requested)
	Events.teleport_node_exit_requested.connect(_on_teleport_node_exit_requested)


func _on_teleport_node_enter_requested(node: TeleportNode):
	%"Camera2D".visible = false
	self.visible = true
	%"TeleportNodes".in_edit_node_mode = true


func _on_teleport_node_exit_requested(node: TeleportNode):
	%"Camera2D".visible = true
	self.visible = false
	%"TeleportNodes".in_edit_node_mode = false
