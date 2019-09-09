extends KinematicBody2D

export(float) var shield_max : = 50.0
var shield_current : float
export(float) var shield_regen : = 1.5
export(float) var regen_cooldown : = 10.0
var regen_active : bool = true

func _ready():
	add_to_group("shield")
	shield_current = shield_max
	
	$RegenCooldown.wait_time = regen_cooldown
	
func _process(delta):
	if not $CollisionShape2D.disabled and shield_current <= 0:
		$CollisionShape2D.disabled = true
	elif $CollisionShape2D.disabled and shield_current > 0:
		$CollisionShape2D.disabled = false
		
	if regen_active:
		shield_current = min(shield_max, shield_current + shield_regen*delta)
		
	var shield_norm = Utils.normalise(shield_current, .15, .5, 0, shield_max) if shield_current > 0 else 0
	$Sprite.modulate.a = shield_norm

func active() -> bool:
	return shield_current > 0

func take_damage(value):
		#Take shield damage
		shield_current = max(0, shield_current - value)
		#cancel regen
		regen_active = false
		$RegenCooldown.start()
		
func _on_Area2D_body_entered(body):
#	print("body entered")
	pass

func _on_Area2D_area_entered(area):
#	print(area.get_parent().get_groups())
	pass	
#	if shield_current <= 0 :
#		return
#
#	if (area.get_parent() != null 
#			and "ammo" in area.get_parent().get_groups() 
#			and not "missile" in area.get_parent().get_groups()
#			and get_parent() != area.get_parent().sender):
#		var ammo = area.get_parent()
#		ammo.explode()
#		#Take shield damage
#		shield_current = max(0, shield_current - ammo.damage)
#		#cancel regen
#		regen_active = false
#		$RegenCooldown.start()


func _on_RegenCooldown_timeout():
	regen_active = true
