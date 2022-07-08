extends Area2D

export var damage = 0

func _on_Hitbox_area_entered(area):
	print("Deal Damage: " + str(damage))
