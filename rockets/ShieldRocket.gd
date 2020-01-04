extends "res://rockets/Rocket.gd"

export (PackedScene) var ShieldBlock
var shieldPositions : Array
var radius : float = 100

func setDefaults():
	moveTime = 0.25
	hp = 2
	damage = 1
	rocketName = "Shield Rocket"
	rocketDesc = "The shield is just some debris that the engineers salvaged from the last rocket they crashed"
	upgrades[1] = "Extra Shield Pieces"
	upgradeCosts[1] = 400
	upgrades[2] = "Double Shield Spin Speed"
	upgradeCosts[2] = 300
	upgrades[3] = "Indestructible Shield Pieces"
	upgradeCosts[3] = 250
	rocketCost = 500
	
	$SpecialTimer.wait_time = 2.5
	$CDTimer.wait_time = 2.5
	specialDesc = "Activate shield for " + str($SpecialTimer.wait_time) + "s (" + str($CDTimer.wait_time) + "s CD)"
	
	#shieldPositions = [Vector2(0, radius),
	#	Vector2(-radius * sin(2*PI/3), radius * cos(2*PI/3)),
	#	Vector2(-radius * sin(-2*PI/3), radius * cos(-2*PI/3)),
	#	Vector2(0, -radius),
	#	Vector2(-radius * sin(PI/3), radius * cos(PI/3)),
	#	Vector2(-radius * sin(-PI/3), radius * cos(-PI/3))]
	shieldPositions = [Vector2(0, radius),
		Vector2(radius,0),
		Vector2(-radius,0),
		Vector2(0, -radius),
		Vector2(radius * sin(PI/4), radius * cos(PI/4)),
		Vector2(radius * sin(3*PI/4), radius * cos(3*PI/4)),
		Vector2(radius * sin(5*PI/4), radius * cos(5*PI/4)),
		Vector2(radius * sin(7*PI/4), radius * cos(7*PI/4))]

### Special ###

#Use special ability
func useThisRocketSpecial():
	var numBlocks
	#Play sound
	if global.getSoundOn() == true:
		$AudioStreamPlayer2D.play()
	#Double shield pieces upgrade
	if global.getRocketList()[rocketName + "Upgrade1Active"] == 1:
		numBlocks = 8
	else:
		numBlocks = 4
	#Create little rotating shields
	var newShieldBlock
	for i in range(0,numBlocks):
		newShieldBlock = ShieldBlock.instance()
		newShieldBlock.position = shieldPositions[i]
		add_child(newShieldBlock)
		#Double shield-block rotation speed upgrade
		if global.getRocketList()[rocketName + "Upgrade2Active"] == 1:
			newShieldBlock.rotationMultiplier *= 2
		#Indestructible shield pieces upgrade
		if global.getRocketList()[rocketName + "Upgrade3Active"] == 1:
			newShieldBlock.hp = 99

#Remove shield blocks after special ends
func resetSpecial():
	for item in get_children():
		if item.is_in_group("bullets"):
			item.queue_free()
