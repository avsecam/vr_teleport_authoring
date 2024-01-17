extends Camera2D


@export var move_speed: float = 2
@export var zoom_speed: float = 0.05


func _process(delta):
	if Input.is_action_pressed("ui_left"):
		self.position.x -= move_speed
	if Input.is_action_pressed("ui_right"):
		self.position.x += move_speed
	if Input.is_action_pressed("ui_up"):
		self.position.y -= move_speed
	if Input.is_action_pressed("ui_down"):
		self.position.y += move_speed
	
	if Input.is_action_just_pressed("mouse_scroll_down"):
		self.zoom = Vector2(self.zoom.x - zoom_speed, self.zoom.y - zoom_speed)
	if Input.is_action_just_pressed("mouse_scroll_up"):
		self.zoom = Vector2(self.zoom.x + zoom_speed, self.zoom.y + zoom_speed)
