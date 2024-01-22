extends Control


const connection_entry: PackedScene = preload("res://src/ConnectionEntry.tscn")

@onready var connection_list: VBoxContainer = $LeftUI/VBoxContainer/ConnectionList

@onready var file_dialog_button: Button = $Container/HBoxContainer/Add
@onready var file_dialog: FileDialog = $FileDialog

@onready var add_button: Button = $Container/HBoxContainer/Add
@onready var delete_button: Button = $Container/HBoxContainer/Delete
@onready var edit_button: Button = $Container/HBoxContainer/Edit
@onready var enter_button: Button = $Container/HBoxContainer/Enter


func _ready():
	file_dialog_button.pressed.connect(_on_file_dialog_button_pressed)
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	
	delete_button.pressed.connect(_on_delete_button_pressed)
	edit_button.pressed.connect(_on_edit_button_pressed)
	enter_button.pressed.connect(_on_enter_button_pressed)
	
	Events.teleport_node_enter_requested.connect(_on_teleport_node_enter_requested)
	Events.teleport_node_exit_requested.connect(_on_teleport_node_exit_requested)
	Events.teleporter_add_requested.connect(_on_teleporter_add_requested)
	
	Events.connection_entry_select_requested.connect(_on_connection_entry_select_requested)
	Events.connection_entry_delete_requested.connect(_on_connection_entry_delete_requested)


func _process(delta):
	var authoring: TeleportAuthor = self.owner
	
	# Add button rendering
	add_button.disabled = authoring.in_edit_node_mode or authoring.in_edit_connections_mode
	
	# Delete button rendering
	if authoring.child_selected() == null \
		or authoring.in_edit_connections_mode \
		or authoring.in_edit_node_mode:
		delete_button.disabled = true
	else:
		delete_button.disabled = false
	
	# Edit button rendering
	edit_button.disabled = authoring.child_selected() == null or authoring.in_edit_node_mode
	edit_button.text = "CONFIRM" if authoring.in_edit_connections_mode else "EDIT CONNECTIONS"
	
	# Enter button rendering
	enter_button.disabled = authoring.child_selected() == null or authoring.in_edit_connections_mode
	enter_button.text = "CONFIRM" if authoring.in_edit_node_mode else "ENTER NODE"
	
	# Connection list rendering
	connection_list.visible = authoring.in_edit_node_mode


func update_connection_list(node: TeleportNode):
	# Make number of connection entries equal the number of connections
	var difference = connection_list.get_child_count() - node.teleport_connections.size()
	if difference < 0:
		# Increase amount connection entries
		for i in range(abs(difference)):
			connection_list.add_child(connection_entry.instantiate())
	elif difference > 0:
		# Decrease amount of connection entries
		for i in range(abs(difference)):
			connection_list.get_child(0).queue_free()
	
	# By now, the number of connection entries and teleport connections are equal
	# Connect the entries to each teleport connection
	if connection_list.get_child_count() > 0:
		for i in range(connection_list.get_child_count()):
			var entry: ConnectionEntry = connection_list.get_child(i)
			var connection: String = node.teleport_connections[i]
			entry.connected_to = get_node(connection)


func focus_connection_entry(entry: ConnectionEntry):
	for connection in connection_list.get_children():
		connection.focused = false
	
	var entry_to_focus: ConnectionEntry = connection_list.get_child(connection_list.get_children().find(entry))
	entry_to_focus.focused = true


func _on_file_dialog_button_pressed():
	file_dialog.show()


func _on_file_dialog_file_selected(path: String):
	var teleport_node: TeleportNode = load("res://src/TeleportNode.tscn").instantiate()
	teleport_node.sprite_texture = load(path)
	teleport_node.area_name = path.get_file()
	
	Events.emit_signal("teleport_node_add_requested", teleport_node)


func _on_delete_button_pressed():
	var selected_child: TeleportNode = self.owner.child_selected()
	Events.teleport_node_delete_requested.emit(selected_child)


func _on_edit_button_pressed():
	var authoring: TeleportAuthor = self.owner
	var selected_child: TeleportNode = authoring.child_selected()
	
	if authoring.in_edit_connections_mode:
		Events.teleport_node_edit_confirm_requested.emit(selected_child)
	else:
		Events.teleport_node_edit_requested.emit(selected_child)


func _on_enter_button_pressed():
	var authoring: TeleportAuthor = self.owner
	var selected_child: TeleportNode = authoring.child_selected()
	
	if authoring.in_edit_node_mode:
		Events.teleport_node_exit_requested.emit(selected_child)
	else:
		Events.teleport_node_enter_requested.emit(selected_child)


func _on_teleport_node_enter_requested(node: TeleportNode):
	update_connection_list(node)
	
	if connection_list.get_child_count() > 0:
		# Focus first entry that has no teleporter
		var entry_without_teleporter: ConnectionEntry
		for connection in connection_list.get_children():
			if not (connection as ConnectionEntry).teleporter:
				entry_without_teleporter = connection
				break
		
		if entry_without_teleporter:
			focus_connection_entry(entry_without_teleporter)
		else:
			focus_connection_entry(connection_list.get_child(0))
	
	connection_list.visible = true


func _on_teleport_node_exit_requested():
	for child in connection_list.get_children():
		child.queue_free()
	
	connection_list.visible = false


func _on_teleporter_add_requested(node: TeleportNode, teleporter: Teleporter):
	update_connection_list(node)


func _on_connection_entry_select_requested(entry: ConnectionEntry):
	focus_connection_entry(entry)


func _on_connection_entry_delete_requested(entry: ConnectionEntry):
	pass
