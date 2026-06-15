extends CharacterBody3D

@export var walk_speed : float = 2.0
@export var sprint_speed : float = 6.0
@export var acceleration : float = 30.0
@export var rotation_speed : float = 12.0

@onready var characterModel: Node3D = $CharacterModel

@onready var shader_skins = [
	$CharacterModel/Armature/GeneralSkeleton/Mannequin,
	$CharacterModel/Armature/GeneralSkeleton/Mannequin2,
	$CharacterModel/Armature/GeneralSkeleton/Mannequin3,
	$CharacterModel/Armature/GeneralSkeleton/Mannequin4,
]

var camera : Camera3D

var is_moving : bool = false
var is_sprinting : bool = false
var is_grounded : bool = false
var is_jumping : bool = false
var is_falling : bool = false

var locked_direction: Vector3 = Vector3.ZERO
var locked_speed: float = 0.0

func _ready():
	camera = get_node("Camera3D")

func _physics_process(delta):
	if Input.is_action_just_pressed("change_skin"): change_skin()
	is_grounded = is_on_floor()
	
	if is_grounded:
		is_jumping = false
		is_falling = false
		
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
		# Получаем направления камеры
		var camera_rotation_y = camera.global_transform.basis.get_euler().y
		var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_rotation_y)
		
		# Движение
		is_moving = direction.length() > 0.1
		is_sprinting = Input.is_action_pressed("sprint") and is_moving
		var current_speed = sprint_speed if is_sprinting else walk_speed
		
		var target_velocity = direction * current_speed
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
		
		# Поворот модели
		if direction.length() > 0.1:
			var target_rotation_y = atan2(direction.x, direction.z)
			characterModel.rotation.y = lerp_angle(characterModel.rotation.y, target_rotation_y, rotation_speed * delta)
		
		# Обработка прыжка
		if Input.is_action_just_pressed("jump"):
			velocity.y = 7.0
			is_jumping = true
			locked_direction = direction
			locked_speed = current_speed + 0.5
		
	else:
		velocity.y -= 9.8 * delta * 1.5
		
		# Момент когда начали падать
		if not is_falling and not is_jumping:
			is_falling = true
			var forward = characterModel.global_transform.basis.z
			locked_direction = Vector3(forward.x, 0, forward.z).normalized()
			locked_speed = sprint_speed if is_sprinting else walk_speed
		
		var target_velocity = locked_direction * locked_speed
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
		
		if locked_direction.length() > 0.1:
			var target_rotation_y = atan2(locked_direction.x, locked_direction.z)
			characterModel.rotation.y = lerp_angle(characterModel.rotation.y, target_rotation_y, rotation_speed * delta)
	
	move_and_slide()

var skin_index = 0;
func change_skin():
	skin_index = (skin_index + 1) % len(shader_skins)
	for skin in shader_skins:
		skin.visible = false
	shader_skins[skin_index].visible = true
