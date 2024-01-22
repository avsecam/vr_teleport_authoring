class_name TeleportAuthor
extends Node


@onready var nodes: Node2D = $TeleportNodes

var in_edit_connections_mode := false
var in_edit_node_mode := false


func _ready():
	Events.teleport_node_selected.connect(_on_teleport_node_selected)
	Events.teleport_node_drag_started.connect(_on_teleport_node_drag_started)
	Events.teleport_node_add_requested.connect(_on_teleport_node_add_requested)
	Events.teleport_node_delete_requested.connect(_on_teleport_node_delete_requested)
	Events.teleport_node_edit_requested.connect(_on_teleport_node_edit_requested)
	Events.teleport_node_edit_confirm_requested.connect(_on_teleport_node_edit_confirm_requested)
	Events.teleport_node_connection_add_requested.connect(_on_teleport_node_connection_add_requested)


func _process(delta):
	%TeleportNodes.visible = not in_edit_node_mode


func child_selected():
	for child in nodes.get_children():
		if (child as TeleportNode).selected:
			return child
	return null


func _on_teleport_node_selected(node: TeleportNode):
	if in_edit_connections_mode:
		pass
	else:
		for child in nodes.get_children():
			(child as TeleportNode).selected = false
		
		node.selected = true


func _on_teleport_node_drag_started(node: TeleportNode):
	# Only allow one node to be dragged at any time
	for child in nodes.get_children():
		(child as TeleportNode).can_drag = false
	
	node.can_drag = true


func _on_teleport_node_add_requested(node: TeleportNode):
	# Add node at center of screen
	var node_position: Vector2 = %"Camera2D".position
	node.position = node_position
	
	nodes.add_child(node)


func _on_teleport_node_delete_requested(node: TeleportNode):
	# Delete connections from other nodes
	for child in nodes.get_children():
		# Find node that is being deleted
		for i in (child as TeleportNode).teleport_connections.size():
			var area: NodePath = (child as TeleportNode).teleport_connections[i]
			if area.get_name(area.get_name_count() - 1) == node.name:
				(child as TeleportNode).teleport_connections.remove_at(i)
				break
	
	node.queue_free()


func _on_teleport_node_edit_requested(node: TeleportNode):
	in_edit_connections_mode = true


func _on_teleport_node_edit_confirm_requested(node: TeleportNode):
	in_edit_connections_mode = false


func _on_teleport_node_connection_add_requested(from: TeleportNode, to: TeleportNode):
	var teleport_connections = from.teleport_connections
	
	for i in range(teleport_connections.size()):
		var node: NodePath = teleport_connections[i]
		if node.get_name(node.get_name_count() - 1) == to.name:
			teleport_connections.remove_at(i)
			return
	
	from.add_teleport_connection(to)
