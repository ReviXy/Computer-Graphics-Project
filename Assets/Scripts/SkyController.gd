extends WorldEnvironment

@onready var dirLight = $DirectionalLight3D

func _ready() -> void:
	GlobalLightManager.connect("light_changed", update_light)
	update_light(GlobalLightManager.light)

func update_light(light):
	if light:
		dirLight.visible = true
		(environment.sky.sky_material as ProceduralSkyMaterial).energy_multiplier = 5.0
	else:
		dirLight.visible = false
		(environment.sky.sky_material as ProceduralSkyMaterial).energy_multiplier = 0.5
