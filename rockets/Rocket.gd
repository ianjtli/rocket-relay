extends Area2D

export (PackedScene) var Bullet

var screenSize : Vector2
var moveDistance : int
var scaleDown = 1

#Rocket attributes
var damage : int
var moveTime : float
var rocketName : String
var rocketDesc : String
var specialDesc : String
var rocketCost : int
var upgrades : Array = []
var upgradeCosts : Array = []
#State variables
var state : String = "New"
var hp : int
var targetPosX : int
var specialAvailable : bool = true
#Signals
signal damaged
signal destroyed
signal powerupCollected

### Initialize ###
func _ready():
	if state == "New":
		add_to_group("rockets")
		$Explosion.connect("completed", self, "_on_Explosion_finished")
		upgrades.resize(5)
		upgradeCosts.resize(5)
		
		#Get screen limits
		screenSize = get_viewport().get_visible_rect().size
		moveDistance = screenSize.x / 3 - 30
		#Set camera horizontal limits
		$Camera.limit_left = - screenSize.x / 2
		$Camera.limit_right = screenSize.x / 2
		#Set the rocket lower than the center of the screen
		$Camera.offset = Vector2(0, -220)
		
		#Set default attributes
		setDefaults()
		$SpecialTime.rect_size.x = $SpecialTimer.wait_time * 15
		$CDTime.rect_size.x = $CDTimer.wait_time * 15
		
		position = Vector2(0, 0)
		targetPosX = 0

# Set defaults
func setDefaults():
	moveTime = 0.3
	hp = 3
	damage = 1
	rocketName = "Boring Rocket"
	
	rocketDesc = "It does its job, if its job was to bore its pilot to death"
	upgrades[1] = "Piercing Bullet"
	upgradeCosts[1] = 300
	upgrades[2] = "Triple Shot"
	upgradeCosts[2] = 400
	upgrades[3] = "Shrink Rocket by 30%"
	upgradeCosts[3] = 200
	rocketCost = 500
	
	$SpecialTimer.wait_time = 0.01
	$CDTimer.wait_time = 2
	specialDesc = "Fire a little bullet (" + str($CDTimer.wait_time) + "s CD)"
	
	if global.getRocketList()[rocketName + "Upgrade3Active"] == 1:
		scaleDown = 0.7
	else:
		scaleDown = 1

#Make this rocket active
func toggleActive(on):
	if on:
		show()
		$Camera.current = true
		$Flames.show()
		
		scale = Vector2(1, 1) * scaleDown
		
		#Enable collisions
		$CollisionShape2D.set_deferred("disabled",false)
		for child in get_children():
			if child.has_node("CollisionShape2D"):
				child.get_node("CollisionShape2D").set_deferred("disabled",false)
		#set_collision_layer_bit(0, true) #Player's layer
		#set_collision_mask_bit(1, true) #Detect powerup layer
		#set_collision_mask_bit(2, true) #Detect enemy layer
	else:
		hide()
		state = "Idle"
		$Camera.current = false
		#Stop all movement
		$Flames.hide()
		$Tween.stop_all()
		
		scale = Vector2(0.25, 0.25) * scaleDown
		
		#Disable collisions
		$CollisionShape2D.set_deferred("disabled",true)
		for child in get_children():
			if child.has_node("CollisionShape2D"):
				child.get_node("CollisionShape2D").set_deferred("disabled",true)


### Movement ###
#Left/right movement
func moveLeft():
	state = "MovingLeft"
	if position.x <= 0:
		targetPosX = -moveDistance
	else:
		targetPosX = 0
	
	if $Camera.limit_left < targetPosX:
		$Tween.stop_all()
		$Tween.interpolate_property(self, "position:x", position.x, targetPosX, moveTime * abs(position.x - targetPosX) / 100, \
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()
func moveRight():
	state = "MovingRight"
	if position.x >= 0:
		targetPosX = moveDistance
	else:
		targetPosX = 0
	
	if $Camera.limit_right > targetPosX:
		$Tween.stop_all()
		$Tween.interpolate_property(self, "position:x", position.x, targetPosX, moveTime * abs(position.x - targetPosX) / 100, \
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()
#When movement tween completes, reset anchor positions
func _on_Tween_tween_completed(object, key):
	state = "Idle"


### Events ###
#Hit detection
func _on_Rocket_area_entered(area):
	#Powerup collected
	if area.is_in_group("powerups"):
		emit_signal("powerupCollected", area)
	#Hit obstacle (or inherited classes like enemy)
	elif area.is_in_group("obstacles"):
		#hp -= area.damage
		emit_signal("damaged")
		if hp <= 0:
			explode()
		
		#Damage obstacle/enemy
		area.damagedBy(self)

#Show explosion
func explode():
	#Hide rocket
	$Rocket.hide()
	$Flames.hide()
	$SpecialTime.hide()
	$CDTime.hide()
	#Stop moving
	$Tween.stop_all()
	#Disable collisions during explosion animation
	$CollisionShape2D.set_deferred("disabled",true)
	#Show explosion
	$Explosion.start()

#Delete after explosion is done
func _on_Explosion_finished():
	emit_signal("destroyed")
	queue_free()

### Special ###
#Use special ability
func useSpecial():
	if specialAvailable == true:
		#Start duration timer
		if $SpecialTimer.wait_time > 0:
			$SpecialTimer.start()
			$SpecialTime.show()
		else:
			$CDTimer.start()
			$CDTime.show()
		
		specialAvailable = false
		useThisRocketSpecial()
func useThisRocketSpecial():
		#Shoot bullet
		var newBullet
		var numBullets = 1
		#Play sound
		if global.getSoundOn() == true:
			$AudioStreamPlayer2D.play()
		#Triple bullet upgrade
		if global.getRocketList()[rocketName + "Upgrade2Active"] == 1:
			numBullets = 3
		for i in range(0, numBullets):
			newBullet = Bullet.instance()
			newBullet.position = position + Vector2(0, -80)
			get_parent().add_child(newBullet)
			#Piercing upgrade
			if global.getRocketList()[rocketName + "Upgrade1Active"] == 1:
				newBullet.hp = 2
			#Rotate for triple bullet
			if i == 1:
				newBullet.aimDirection(.25)
			elif i == 2:
				newBullet.aimDirection(-.25)

#Updates cooldown indicators
func _process(delta):
	if !$SpecialTimer.is_stopped():
		$SpecialTime.rect_size.x = $SpecialTimer.time_left * 15
	if !$CDTimer.is_stopped():
		$CDTime.rect_size.x = $CDTimer.time_left * 15

#Special timer ends
func _on_SpecialTimer_timeout():
	#Stop special timer
	$SpecialTimer.stop()
	$SpecialTime.hide()
	
	#Start cooldown timer
	$CDTimer.start()
	$CDTime.show()
	
	#Resets anything the special created
	resetSpecial()
func resetSpecial():
	pass

#Cooldown timer ends
func _on_CDTimer_timeout():
	$CDTimer.stop()
	$CDTime.hide()
	specialAvailable = true
