class_name TeleportNode
extends StaticBody2D


@onready var connections: Node2D = $Connections
@onready var sprite: Sprite2D = $Sprite2D
@onready var line_edit: LineEdit = $LineEdit

@export var sprite_texture_filename: String

@export var area_name: String

@export var teleport_connections: Array # of TeleportNode NodePaths

var teleporters: Array # of Teleporters

var base_rotation: float # normal facing rotation when user enters the node

var selected: bool = false
var can_drag: bool = false


func _ready():
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	
	# Set preview image
	var image = Image.new()
	var err = image.load(sprite_texture_filename)
	if err != OK:
		push_error("Error loading image from ", sprite_texture_filename)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture if sprite_texture_filename else preload("res://icon.svg")
	line_edit.text = area_name
	
	# Make teleport_connections contain absolute NodePaths
	for i in range(teleport_connections.size()):
		teleport_connections[i] = String(get_node(teleport_connections[i]).get_path())


func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_left"):
		Events.teleport_node_drag_started.emit(self)
	elif event.is_action_pressed("mouse_right"):
		var handler: Node = self.get_parent().owner
		if handler.in_edit_connections_mode:
			if not handler.child_selected().get_path() == self.get_path():
				Events.teleport_node_connection_add_requested.emit(handler.child_selected(), self)
		else:
			Events.teleport_node_selected.emit(self)
		
	elif event.is_action_released("mouse_left"):
		can_drag = false


func _process(delta):
	# Make number of lines equal the number of connections
	var difference = connections.get_children().size() - self.teleport_connections.size()
	if difference < 0:
		for i in range(abs(difference)):
			connections.add_child(Line2D.new())
	elif difference > 0:
		for i in range(abs(difference)):
			var node_to_remove = connections.get_child(0)
			connections.remove_child(node_to_remove)
			node_to_remove.queue_free()
	
	# Show indicator if selected
	$ColorRect.visible = selected
	
	# Drag
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_drag:
		self.position = get_global_mouse_position()
	
	# Draw path lines
	for i in range(teleport_connections.size()):
		var node: String = teleport_connections[i]
		var line: Line2D = connections.get_child(i)
		if get_node_or_null(node) == null:
			continue
		
		line.clear_points()
		line.add_point(self.global_position)
		line.add_point((get_node(node) as TeleportNode).global_position)
		line.position = -self.global_position
		
		if self.selected:
			line.default_color = Color(1, 0, 0)
			
			# Check teleporters if there is a corresponding teleporter with
			# a teleport_location that matches node
			for teleporter in teleporters:
				if (teleporter as Teleporter).teleport_location == get_node(node):
					line.default_color = Color(0, 0, 1)
		else:
			line.default_color = Color(1, 1, 1, 0.5)
		
		line.width = 4 if self.selected else 2


func add_teleport_connection(node: TeleportNode):
	teleport_connections.append(node.get_path())


func _on_line_edit_text_changed(new_text: String):
	area_name = new_text


func _on_line_edit_text_submitted(new_text: String):
	line_edit.release_focus()
