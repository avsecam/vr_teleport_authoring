extends Control

const MODAL_COLOR = Color("#0000004f")
const TRIGGER_ENTRY = preload("res://src/events/TriggerEntry.tscn")
const LOCKS_SETTER = preload("res://src/events/LocksSetter.tscn")

@onready var text_edit: TextEdit = $MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/TextEdit
@onready var add_trigger_button: Button = $MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Button

@onready var trigger_list: VBoxContainer = $MarginContainer/MarginContainer/VBoxContainer/TriggerNames

func _ready():
	$EventFlagsButton.pressed.connect(_on_EventFlagsButton_pressed)
	Events.event_flags_toggle_requested.connect(_on_event_flags_toggle_requested)
	
	self.add_trigger_button.pressed.connect(_on_add_trigger_button_pressed)
	Events.trigger_add_confirmed.connect(_on_trigger_add_confirmed)
	Events.trigger_delete_confirmed.connect(_on_trigger_delete_confirmed)
	
	Events.locks_toggle_requested.connect(_on_locks_toggle_requested)

func _process(_delta):
	if not text_edit.text:
		add_trigger_button.disabled = true
	else:
		add_trigger_button.disabled = false

func _on_EventFlagsButton_pressed():
	Events.event_flags_toggle_requested.emit()

func _on_event_flags_toggle_requested():
	if $MarginContainer.visible:
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		self.color = Color("transparent")
	else:
		self.mouse_filter = Control.MOUSE_FILTER_STOP
		self.color = MODAL_COLOR
	$MarginContainer.visible = not $MarginContainer.visible

func _on_add_trigger_button_pressed():
	var trigger_name = text_edit.text
	
	if EventFlags.exists(trigger_name.to_lower()):
		push_warning("Trigger ", trigger_name, " already exists.")
	else:
		text_edit.text = ""
		Events.trigger_add_requested.emit(trigger_name)

func _on_trigger_add_confirmed(trigger_name: String):
	var entry: TriggerEntry = TRIGGER_ENTRY.instantiate()
	entry.set_trigger_name(trigger_name)
	trigger_list.add_child(entry)

func _on_trigger_delete_confirmed(trigger_name: String):
	for child in trigger_list.get_children():
		if (child as TriggerEntry).trigger_name == trigger_name:
			child.queue_free()
			break

func _on_locks_toggle_requested(teleporter: Teleporter):
	var existing_locks_setter = get_tree().get_nodes_in_group("LocksSetter")
	if existing_locks_setter.size() > 0:
		remove_child(existing_locks_setter[0])
		existing_locks_setter[0].queue_free()
	
	var locks_setter_instance = LOCKS_SETTER.instantiate()
	locks_setter_instance.teleporter = teleporter
	add_child(locks_setter_instance)
