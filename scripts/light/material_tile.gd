extends StaticBody2D
class_name MaterialTile

enum MaterialType { OPAQUE, TRANSPARENT, TRANSLUCENT }

@export var material_type : MaterialType = MaterialType.OPAQUE
@export_range(0.0, 1.0) var translucent_attenuation : float = 0.5

func _ready():
	add_to_group("LightMaterials")
	match material_type:
		MaterialType.OPAQUE: add_to_group("OpaqueMaterials")
		MaterialType.TRANSPARENT: add_to_group("TransparentMaterials")
		MaterialType.TRANSLUCENT: add_to_group("TranslucentMaterials")

func get_material_type() -> int:
	return material_type

func get_attenuation() -> float:
	if material_type == MaterialType.TRANSLUCENT:
		return translucent_attenuation
	return 1.0
