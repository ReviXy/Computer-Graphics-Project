extends Camera3D

@export var mouse_sensitivity : float = 0.002
@export var zoom_speed : float = 0.25
@export var min_zoom : float = 0.5
@export var max_zoom : float = 5.0
@export var initial_distance : float = 3.0
@export var pivot_point : Vector3 = Vector3(0, 1.5, 0)
@export var collision_mask : int = 1
@export var smooth_speed : float = 15.0

var yaw : float = 0.0
var pitch : float = 0.0
var desired_distance : float
var current_distance : float

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	desired_distance = initial_distance
	current_distance = initial_distance
	
	# Начальный поворот камеры за спину персонажа
	yaw = deg_to_rad(180)  # Сзади
	pitch = deg_to_rad(20)  # Небольшой наклон вниз
	
	update_camera_position()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch += event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-30), deg_to_rad(60))  # Ограничение для платформера
		update_camera_position()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			desired_distance = max(min_zoom, desired_distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			desired_distance = min(max_zoom, desired_distance + zoom_speed)

func _process(delta):
	update_camera_position()
	
	if Input.is_action_just_pressed("cursor_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_camera_position():
	var direction = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)).normalized()
	
	var parent_node = get_parent()
	var pivot_global_pos = (parent_node.global_position + pivot_point) if parent_node else pivot_point
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pivot_global_pos, 
		pivot_global_pos + direction * desired_distance, 
		collision_mask)
	query.exclude = [self, parent_node]
	
	var result = space_state.intersect_ray(query)
	
	var safe_distance = desired_distance
	if result:
		var hit_distance = pivot_global_pos.distance_to(result.position)
		safe_distance = max(min_zoom, hit_distance - 0.1)
	
	current_distance = lerp(current_distance, safe_distance, smooth_speed * get_process_delta_time())
	
	var offset = direction * current_distance
	
	if parent_node:
		global_position = pivot_global_pos + offset
	else:
		position = pivot_point + offset
	
	look_at(pivot_global_pos, Vector3.UP)
