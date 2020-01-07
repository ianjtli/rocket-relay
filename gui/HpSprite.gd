extends Sprite

func _ready():
	add_to_group("hpSprites")
	
	#Temporary size increase animation as positive feedback for gaining HP
	$Tween.interpolate_property(self, "scale", scale, Vector2(0.4,0.4), .2, \
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

#Revert to original size
func _on_Tween_tween_completed(object, key):
	if scale == Vector2(0.4,0.4):
		$Tween.interpolate_property(self, "scale", scale, Vector2(0.3,0.3), .2, \
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()