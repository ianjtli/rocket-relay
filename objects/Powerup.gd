extends Area2D

var scoreIncrease : int
var hpIncrease : int
var velocity : Vector2
var activated : bool = false

func _ready():
	add_to_group("powerups")
	_onready()
func _onready():
	scoreIncrease = 3
	hpIncrease = 0
	velocity = Vector2(0, 400)

#Move
func _process(delta):
	position += velocity * delta

#Play collection animation, then delete
func _on_Powerup_area_entered(area):
	if area.is_in_group("rockets"):
		#Disable collision
		collision_layer = 0
		collision_mask = 0
		#Animate
		$Tween.interpolate_property(self, "modulate", Color(1,1,1,.9), Color(1,1,1,0.25), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.interpolate_property(self, "position", position, Vector2(-240 , position.y - 600), 0.3, \
				Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		#Play sound
		if global.getSoundOn() == true:
			$AudioStreamPlayer2D.play()

#Delete after animation done
func _on_Tween_tween_completed(object, key):
	queue_free()

#Activate when first visible
func _on_VisibilityNotifier2D_screen_entered():
	if activated == false:
		activated = true

#If moves offscreen when activated, delete
func _on_VisibilityNotifier2D_screen_exited():
	if activated == true:
		queue_free()