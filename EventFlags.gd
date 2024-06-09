extends Node

# { "triggerName": bool }
@export var data: Dictionary

func _ready():
	Events.trigger_add_requested.connect(_on_trigger_add_requested)
	Events.trigger_delete_requested.connect(_on_trigger_delete_requested)
	Events.trigger_toggle_requested.connect(_on_trigger_toggle_requested)
	Events.trigger_set_requested.connect(_on_trigger_set_requested)

func exists(trigger_name: String):
	return data.has(trigger_name)

func _on_trigger_add_requested(trigger_name: String):
	if self.exists(trigger_name):
		push_warning("Trigger ", trigger_name, " already exists.")
	data[trigger_name] = false
	print_debug("Trigger ", trigger_name, " added.")

func _on_trigger_delete_requested(trigger_name: String):
	if not self.exists(trigger_name):
		push_warning("Trigger ", trigger_name, " does not exist.")
	data.erase(trigger_name)
	Events.trigger_delete_confirmed.emit(trigger_name)
	print_debug("Trigger ", trigger_name, " deleted.")

func _on_trigger_toggle_requested(trigger_name: String):
	if not self.exists(trigger_name):
		push_error("Trigger ", trigger_name, " does not exist.")
		return
	data[trigger_name] = not data[trigger_name]
	print_debug("Trigger ", trigger_name, " toggled.")

func _on_trigger_set_requested(trigger_name: String, value: bool):
	if not self.exists(trigger_name):
		push_error("Trigger ", trigger_name, " does not exist.")
		return
	data[trigger_name] = value
	print_debug("Trigger ", trigger_name, " set to ", value, ".")
