extends "res://rockets/Rocket.gd"

export (PackedScene) var Sword
var phased : bool = false

func setDefaults():
	moveTime = 0.2
	hp = 2
	damage = 1
	rocketName = "Sword Rocket"
	
	rocketDesc = "While other rockets were shooting missiles and having a blast, sword rocket studied the blade"
	upgrades[1] = "Double sword length"
	upgradeCosts[1] = 400
	upgrades[2] = "Immune during slash"
	upgradeCosts[2] = 250
	upgrades[3] = "Two slashes"
	upgradeCosts[3] = 350
	rocketCost = 500
	
	#Two sword swings upgrade
	if global.getRocketList()[rocketName + "Upgrade3Active"] == 1:
		$SpecialTimer.wait_time = .5
	else:
		$SpecialTimer.wait_time = .25
	$CDTimer.wait_time = 2
	specialDesc = "Slash sword for " + str($SpecialTimer.wait_time) + "s (" + str($CDTimer.wait_time) + "s CD)"

#Hit detection
func _on_Rocket_area_entered(area):
	#Powerup collected
	if area.is_in_group("powerups"):
		emit_signal("powerupCollected", area)
	#Hit obstacle (or inherited classes like enemy)
	elif area.is_in_group("obstacles"):
		if phased == false:
			emit_signal("damaged")
			if hp <= 0:
				explode()
		
		#Damage obstacle/enemy
		#Phase destroys enemy upgrade
		if phased == false or global.getRocketList()[rocketName + "Upgrade2Active"] == 1:
			area.damagedBy(self)

### Special ###
#Use special ability
func useThisRocketSpecial():
	#Play sound
	if global.getSoundOn() == true:
		$AudioStreamPlayer2D.play()
	
	#Create and swing sword
	var sword
	sword = Sword.instance()
	add_child(sword)
	#Double sword length upgrade
	if global.getRocketList()[rocketName + "Upgrade1Active"] == 1:
		sword.scale = Vector2(1,2)
	
	#Immune during sword slash upgrade
	if global.getRocketList()[rocketName + "Upgrade2Active"] == 1:
		phased = true
		$Rocket.modulate = Color(.5,.5,.5)
		$Flames.modulate = Color(.5,.5,.5)

#Reset collisions and opacity after special ends
func resetSpecial():
	phased = false
	$Rocket.modulate = Color(1,1,1)
	$Flames.modulate = Color(1,1,1)