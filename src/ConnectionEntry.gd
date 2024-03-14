class_name ConnectionEntry
extends HBoxContainer

const focused_color := Color(0, 1, 1)
const unfocused_color := Color(1, 1, 1)

@export var focused: bool = false

@export var teleporter: Teleporter
@export var connected_to: TeleportNode:
	set(value):
		area_name_button.text = value.area_name
		connected_to = value

@onready var area_name_button: Button = $AreaName
@onready var delete_button: Button = $Delete

func _ready():
	area_name_button.pressed.connect(_on_area_name_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	
	area_name_button.text = connected_to.area_name if connected_to else ""

func _process(_delta):
	delete_button.visible = teleporter != null
	modulate = focused_color if focused else unfocused_color

func _on_area_name_button_pressed():
	Events.connection_entry_select_requested.emit(self)

func _on_delete_button_pressed():
	Events.connection_entry_delete_requested.emit(self)
