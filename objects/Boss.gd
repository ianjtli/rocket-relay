extends "res://objects/Enemy.gd"

var state : String
var anchorPos : Vector2
const idlePosition : int = -550
var invincibility : bool = false

#Initialize
func _onready():
	hp = 6
	damage = 1
	anchorPos = Vector2(-9999,-9999)
	
	#Get screen limits
	screenSize = get_viewport().get_visible_rect().size
	horizontalMove = screenSize.x / 5
	
	velocity = Vector2(0,300)
	score = 50
	
	$HPGone.show()
	$HPLeft.show()
	
	state = "approaching"

#Movement
func _callprocess(delta):
	position += velocity * delta
	if activated == true and !$Tween.is_active():
		if state == "approaching":
			if position.y > idlePosition:
				state = "idle"
				velocity = Vector2(0,0)
				anchorPos = position
		elif state == "idle":
			if anchorPos == position:
				moveHorizontal((randi() % 3 - 1) * horizontalMove)
		elif state == "dive":
			if anchorPos == position:
				dive()
		elif state == "retreat":
			if anchorPos == position:
				retreat()
		
#Process movement
func moveHorizontal(xDist):
	anchorPos = position
	#Limit horizontal movement
	if position.x <= -2 * horizontalMove:
		xDist = abs(xDist)
	elif position.x >= 2 * horizontalMove:
		xDist = -abs(xDist)
	
	$Tween.interpolate_property(self, "position:x", position.x, position.x+xDist, 1.2, \
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func dive():
	anchorPos = position
	$Tween.interpolate_property(self, "position:y", position.y, 50, 1.3, \
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func retreat():
	anchorPos = position
	$Tween.interpolate_property(self, "position:y", position.y, idlePosition, 1.5, \
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

#When movement tween completes, reset anchor position
func _on_Tween_tween_completed(object, key):
	anchorPos = position
	if state == "idle":
		if randf() < 0.35:
			state = "dive"
	elif state == "dive":
		state = "retreat"
	elif state == "retreat":
		state = "idle"

#Decrease hp if hit
func damagedBy(area):
	if (area.is_in_group("rockets") or area.is_in_group("bullets")) and invincibility == false:
		hp = hp - area.damage
		update_hp()
		if hp <= 0:
			explode()
		else:
			$SmallExplosion.start()
			#Turn on momentary invincibility
			invincibility = true
			$InvincibilityTimer.start()
			flash()
#Invincible flash
func _on_inv_flash_completed(object, key):
	flash()
func flash():
	if invincibility == true:
		if $Sprite.modulate == Color(1,1,1,1):
			$Sprite/Tween.interpolate_property(self,"modulate",$Sprite.modulate,Color(.6,.2,.2), .1, \
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		else:
			$Sprite/Tween.interpolate_property(self,"modulate",$Sprite.modulate,Color(1,1,1,1), .1, \
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Sprite/Tween.start()
	else:
		$Sprite.modulate = Color(1,1,1,1)
#Invincibility runs out
func _on_InvincibilityTimer_timeout():
	invincibility = false
	#Stop flashing
	$Sprite/Tween.stop_all()
	$Sprite/Tween.interpolate_property(self,"modulate",$Sprite.modulate,Color(1,1,1,1), .1, \
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Sprite/Tween.start()

#Override delete if offscreen
func _on_VisibilityNotifier2D_screen_exited():
	pass

