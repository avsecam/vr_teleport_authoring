extends Node

enum ActiveAuthoring {
	Teleport, Event
}

var active_authoring = ActiveAuthoring.Teleport

func _ready():
	Events.switch_requested.connect(_on_switch_requested)

func _on_switch_requested():
	if active_authoring == ActiveAuthoring.Teleport:
		active_authoring = ActiveAuthoring.Event
	else:
		active_authoring = ActiveAuthoring.Teleport
