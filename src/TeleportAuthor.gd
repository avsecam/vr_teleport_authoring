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
	
	Events.export_requested.connect(_on_export_requested)
	Events.save_requested.connect(_on_save_requested)


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
		if not node.selected:
			for child in nodes.get_children():
				(child as TeleportNode).selected = false
			
			node.selected = true
		else:
			node.selected = false


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
		var node_name: String = teleport_connections[i]
		if node_name == to.name:
			teleport_connections.remove_at(i)
			return
	
	from.add_teleport_connection(to.name)


# TODO: Dont allow same named nodes
func _on_export_requested():
	var folder_name: String = "exported_" + str(floor(Time.get_unix_time_from_system()))
	var dir: DirAccess = DirAccess.open("user://")
	if dir:
		dir.make_dir(folder_name)
	
	var full_dir_name: String = "user://" + folder_name + "/"
	
	for i in nodes.get_child_count():
		var node: TeleportNode = nodes.get_child(i)
		var filename: String = full_dir_name + node.area_name.to_pascal_case() + ".json"
		var image_filename: String = full_dir_name + node.area_name.to_pascal_case() + ".jpg"
		
		var image = Image.load_from_file(node.sprite_texture_filename)
		image.save_jpg(image_filename)
		
		var exported_tp_node = {
			"panorama_texture_filename": node.area_name.to_pascal_case() + ".jpg",
			"area_name": node.area_name,
			"base_rotation": node.base_rotation if node.base_rotation else 0,
			"teleporter_positions": [] # {position, teleport_location_filepath}
		}
		
		for j in node.teleporters.size():
			var teleporter: Teleporter = node.teleporters[j]
			(exported_tp_node.teleporter_positions as Array).append({
				"position_x": teleporter.position.x,
				"position_y": teleporter.position.y,
				"position_z": teleporter.position.z,
				"teleport_location_filename": teleporter.teleport_location.area_name.to_pascal_case() + ".json"
			})
		
		var file = FileAccess.open(filename, FileAccess.WRITE)
		file.store_string(JSON.stringify(exported_tp_node))
		
	
	# Open folder containing scenes
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(full_dir_name))


func _on_save_requested():
	var folder_name: String = "saved_" + str(floor(Time.get_unix_time_from_system()))
	var dir: DirAccess = DirAccess.open("user://")
	if dir:
		dir.make_dir(folder_name)
	
	var full_dir_name: String = "user://" + folder_name + "/"
	
	# Save children of TeleportNodes
	for i in %TeleportNodes.get_child_count():
		var teleport_node: TeleportNode = %TeleportNodes.get_child(i)
		
		var saved_teleport_node: SavedTeleportNode
		saved_teleport_node.area_name = teleport_node.area_name
		saved_teleport_node.sprite_texture_filename = teleport_node.sprite_texture_filename
#		for j in teleport_node.teleport_connections.size():
			
		
#		var packed: PackedScene = PackedScene.new()
#		packed.pack(savedTeleportNode)
#		var err = ResourceSaver.save(packed, full_dir_name + savedTeleportNode.name + ".tscn")
	
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(full_dir_name))
	Events.save_finished.emit()
