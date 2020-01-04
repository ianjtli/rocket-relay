extends "res://rockets/Rocket.gd"

var phased : bool = false

func setDefaults():
	moveTime = 0.15
	hp = 2
	damage = 1
	rocketName = "Mini Rocket"
	rocketDesc = "A shy rocket that likes avoiding social interactions with enemy spaceships"
	upgrades[1] = "Phase Destroys Enemies"
	upgradeCosts[1] = 400
	upgrades[2] = "Auto-trigger Phase Ability"
	upgradeCosts[2] = 450
	upgrades[3] = "+.75s Phase Duration"
	upgradeCosts[3] = 350
	rocketCost = 500
	
	#Extra 1s phase duration upgrade
	if global.getRocketList()[rocketName + "Upgrade3Active"] == 1:
		$SpecialTimer.wait_time = 2.25
	else:
		$SpecialTimer.wait_time = 1.5
	$CDTimer.wait_time = 3
	specialDesc = "Phase out for " + str($SpecialTimer.wait_time) + "s (" + str($CDTimer.wait_time) + "s CD)"

#Hit detection
func _on_Rocket_area_entered(area):
	#Powerup collected
	if area.is_in_group("powerups"):
		emit_signal("powerupCollected", area)
	#Hit obstacle (or inherited classes like enemy)
	elif area.is_in_group("obstacles"):
		#Auto trigger special upgrade
		if specialAvailable == true and global.getRocketList()[rocketName + "Upgrade2Active"] == 1:
			useSpecial()
		
		if phased == false:
			#hp -= area.damage
			emit_signal("damaged")
			if hp <= 0:
				explode()
		
		#Damage obstacle/enemy
		#Phase destroys enemy upgrade
		if phased == false or global.getRocketList()[rocketName + "Upgrade1Active"] == 1:
			area.damagedBy(self)

### Special ###

#Use special ability
func useThisRocketSpecial():
	#Play sound
	if global.getSoundOn() == true:
		$AudioStreamPlayer2D.play()
	phased = true
	$Rocket.modulate = Color(.5,.5,.5)
	$Flames.modulate = Color(.5,.5,.5)

#Reset collisions and opacity after special ends
func resetSpecial():
	phased = false
	#Allow collisions again (if not in preview mode)
	#if activated:
		#$CollisionShape2D.set_deferred("disabled",false)
		#set_collision_layer_bit(0, true) #Player's layer
		#set_collision_mask_bit(1, true) #Detect powerup layer
		#set_collision_mask_bit(2, true) #Detect enemy layer
	$Rocket.modulate = Color(1,1,1)
	$Flames.modulate = Color(1,1,1)
