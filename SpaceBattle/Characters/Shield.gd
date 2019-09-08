extends Sprite

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
	if regen_active:
		shield_current = min(shield_max, shield_current + shield_regen*delta)
		
	var shield_norm = Utils.normalise(shield_current, .15, .5, 0, shield_max) if shield_current > 0 else 0
	modulate.a = shield_norm

func _on_Area2D_body_entered(body):
	print("test")


func _on_Area2D_area_entered(area):
	if shield_current <= 0 :
		return
		
	if (area.get_parent() != null 
			and "ammo" in area.get_parent().get_groups() 
			and not "missile" in area.get_parent().get_groups()):
		var ammo = area.get_parent()
		ammo.explode()
		#Take shield damage
		shield_current = max(0, shield_current - ammo.damage)
		if shield_current == 0:
			$Area2D/CollisionShape2D.disabled = true
		else:
			$Area2D/CollisionShape2D.disabled = false
		#cancel regen
		regen_active = false
		$RegenCooldown.start()


func _on_RegenCooldown_timeout():
	regen_active = true
