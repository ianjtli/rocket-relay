extends Area2D

var damage : int
var hp : int
var numSwings : int

func _ready():
	add_to_group("bullets")
	damage = 1
	hp = 100
	
	#Swing the sword
	$Tween.interpolate_property(self, "rotation_degrees", -80, 70, .25, \
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Sword_area_entered(area):
	if "damage" in area:
		hp -= area.damage
	if hp <= 0:
		queue_free()
	
	#Damage obstacle/enemy
	area.damagedBy(self)

#Delete after sword is swung
func _on_Tween_tween_completed(object, key):
	numSwings += 1
	#Two swings upgrade
	if global.getRocketList()[get_parent().rocketName + "Upgrade3Active"] == 1 and numSwings < 2:
		#Reverse the sword
		#scale = Vector2(-scale.x,scale.y)
		$Tween.interpolate_property(self, "rotation_degrees", -80, 70, .3, \
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		queue_free()
