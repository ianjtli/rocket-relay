extends "res://objects/Obstacle.gd"

var anchorPosX : int
var horizontalMove : int

#Initialize
func _onready():
	hp = 1
	damage = 1
	anchorPosX = -9999
	velocity = Vector2(0, 300)
	horizontalMove = 0
	score = 2
func initialize(speed, leftRight):
	velocity = Vector2(0, speed)
	horizontalMove = leftRight

#Movement
func _callprocess(delta):
	position += velocity * delta
	#Random x-movement
	if activated == true:
		if anchorPosX == -9999:
			anchorPosX = position.x
		elif position.x == anchorPosX:
			move((randi() % 3 - 1) * horizontalMove)
#Process movement
func move(xDist):
	anchorPosX = position.x
	$Tween.interpolate_property(self, "position:x", position.x, position.x-xDist, 2, \
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
#When movement tween completes, reset anchor position
func _on_Tween_tween_completed(object, key):
	anchorPosX = position.x

#Show explosion
func explode():
	#Hide rocket
	$Sprite.hide()
	$Flames.hide()
	#Disable collisions during explosion animation
	$CollisionShape2D.set_deferred("disabled",true)
	#set_collision_layer_bit(2, false) #Enemies layer
	#set_collision_mask_bit(0, false) #Detect player's layer
	#set_collision_mask_bit(3, false) #Detect bullet's layer
	#Show explosion
	$Explosion.start()
	#Trigger enemy destroyed actions
	emit_signal("destroyed", score)
	
	#Stop movement
	velocity = Vector2(0,0)
