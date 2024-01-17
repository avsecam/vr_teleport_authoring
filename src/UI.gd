extends Control


@onready var file_dialog_button: Button = $Container/HBoxContainer/Add
@onready var file_dialog: FileDialog = $FileDialog

@onready var delete_button: Button = $Container/HBoxContainer/Delete
@onready var edit_button: Button = $Container/HBoxContainer/Edit
@onready var enter_button: Button = $Container/HBoxContainer/Enter


func _ready():
	file_dialog_button.pressed.connect(_on_file_dialog_button_pressed)
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	
	delete_button.pressed.connect(_on_delete_button_pressed)
	edit_button.pressed.connect(_on_edit_button_pressed)
	enter_button.pressed.connect(_on_enter_button_pressed)


func _process(delta):
	var teleport_node_handler: TeleportNodeHandler = get_node("%TeleportNodes")
	
	# Delete button rendering
	if teleport_node_handler.child_selected() == null or teleport_node_handler.in_edit_connections_mode:
		delete_button.disabled = true
	else:
		delete_button.disabled = false
	
	# Edit button rendering
	edit_button.disabled = teleport_node_handler.child_selected() == null
	edit_button.text = "CONFIRM" if teleport_node_handler.in_edit_connections_mode else "EDIT CONNECTIONS"
	
	# Enter button rendering
	enter_button.disabled = teleport_node_handler.child_selected() == null
	enter_button.text = "CONFIRM" if teleport_node_handler.in_edit_node_mode else "ENTER NODE"


func _on_file_dialog_button_pressed():
	file_dialog.show()


func _on_file_dialog_file_selected(path: String):
	var teleport_node: TeleportNode = load("res://src/TeleportNode.tscn").instantiate()
	teleport_node.sprite_texture = load(path)
	teleport_node.area_name = path.get_file()
	
	Events.emit_signal("teleport_node_add_requested", teleport_node)


func _on_delete_button_pressed():
	var selected_child: TeleportNode = (get_node("%TeleportNodes") as TeleportNodeHandler).child_selected()
	Events.teleport_node_delete_requested.emit(selected_child)


func _on_edit_button_pressed():
	var teleport_node_handler: TeleportNodeHandler = get_node("%TeleportNodes")
	var selected_child: TeleportNode = teleport_node_handler.child_selected()
	
	if teleport_node_handler.in_edit_connections_mode:
		Events.teleport_node_edit_confirm_requested.emit(selected_child)
	else:
		Events.teleport_node_edit_requested.emit(selected_child)


func _on_enter_button_pressed():
	var teleport_node_handler: TeleportNodeHandler = get_node("%TeleportNodes")
	var selected_child: TeleportNode = teleport_node_handler.child_selected()
	
	if teleport_node_handler.in_edit_node_mode:
		Events.teleport_node_exit_requested.emit(selected_child)
	else:
		Events.teleport_node_enter_requested.emit(selected_child)
