extends Area2D

var hp : int
var maxHp : int
var damage : int
var activated : bool = false
var velocity : Vector2
var score : int
var screenSize : Vector2

signal destroyed

#Initialize
func _ready():
	_onready()
	add_to_group("obstacles")
	
	maxHp = hp
	
	$Explosion.connect("completed", self, "_on_Explosion_finished")
func _onready():
	hp = 1
	damage = 1
	velocity = Vector2(0, 300)
	score = 2

#Move
func _process(delta):
	_callprocess(delta)
func _callprocess(delta):
	position += velocity * delta

#Decrease hp if hit
func damagedBy(area):
	if area.is_in_group("rockets") or area.is_in_group("bullets"):
		hp = hp - area.damage
		update_hp()
		if hp <= 0:
			explode()
		else:
			$SmallExplosion.start()

#Update the hp bar
func update_hp():
	$HPLeft/Tween.interpolate_property($HPLeft, "rect_size", $HPLeft.rect_size, Vector2(60 * hp / maxHp, $HPLeft.rect_size.y), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$HPLeft/Tween.start()

#Show explosion
func explode():
	#Hide rocket
	$Rect.hide()
	#Disable collisions during explosion animation
	$CollisionShape2D.set_deferred("disabled",true)
	#Show explosion
	$Explosion.start()
	#Trigger enemy destroyed actions
	emit_signal("destroyed", score)

#Delete after explosion is done
func _on_Explosion_finished():
	queue_free()

#Activate when first visible
func _on_VisibilityNotifier2D_screen_entered():
	if activated == false:
		activated = true

#If moves offscreen when activated, delete
func _on_VisibilityNotifier2D_screen_exited():
	if activated == true and $Explosion.playing == false:
		queue_free()

#Hide small explosion after complete
func _on_SmallExplosion_animation_finished():
	$SmallExplosion.hide()
