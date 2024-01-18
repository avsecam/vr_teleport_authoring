class_name ConnectionEntry
extends HBoxContainer


@export var teleporter: Teleporter
@export var connected_to: TeleportNode:
	set(value):
		area_name_button.text = value.area_name

@onready var area_name_button: Button = $AreaName
@onready var delete_button: Button = $Delete


func _ready():
	area_name_button.text = connected_to.area_name if connected_to else ""


func _process(_delta):
	delete_button.visible = teleporter != null
