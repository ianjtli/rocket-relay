extends "res://objects/Powerup.gd"

func _onready():
	scoreIncrease = 0
	hpIncrease = 1
	velocity = Vector2(0, 320)

#Play collection animation, then delete
func _on_Powerup_area_entered(area):
	if area.is_in_group("rockets"):
		#Play sound
		if global.getSoundOn() == true:
			$AudioStreamPlayer2D.play()
		#Disable collision
		collision_layer = 0
		collision_mask = 0
		#Animate
		$Tween.interpolate_property(self, "modulate", Color(1,1,1,.9), Color(1,1,1,0.25), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.interpolate_property(self, "position", position, Vector2(-240 , position.y - 300), 0.2, \
				Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()