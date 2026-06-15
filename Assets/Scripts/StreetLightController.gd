extends Node3D

@onready var spotLight : SpotLight3D = $SpotLight3D
@onready var lampMaterial : StandardMaterial3D = ($RootNode/StreetLight).mesh.surface_get_material(1)

func _ready() -> void:
	GlobalLightManager.connect("light_changed", update_light)
	update_light(GlobalLightManager.light)

func update_light(light):
	if light:
		spotLight.visible = false
		lampMaterial.emission_enabled = false
	else:
		spotLight.visible = true
		lampMaterial.emission_enabled = true
