extends Control

var thisRocket : Node
var upgradeNum : int
signal purchaseComplete

onready var screenSize = get_viewport().get_visible_rect().size

func _ready():
	pass

func showUpgrade(rocket,upgrade):
	#Details for upgrade to be purchased
	thisRocket = rocket
	upgradeNum = upgrade
	
	#Update GUI
	show()
	$VBox/PurchaseButton.show()
	
	#Upgrade number zero means player is purchasing the rocket itself
	if upgradeNum == 0:
		$VBox/Label.text = "\nBuy " + thisRocket.rocketName 
		$VBox/Label.text += " for " + str(thisRocket.rocketCost) + " credits?" 
	else:
		$VBox/Label.text = "\nBuy \"" + thisRocket.upgrades[upgradeNum] + "\" upgrade"
		$VBox/Label.text += " for " + thisRocket.rocketName
		$VBox/Label.text += " for " + str(thisRocket.upgradeCosts[upgradeNum]) + " credits?"
	
	#Pause rocket movement
	get_tree().paused = true

#Purchase rocket or upgrade
func _on_PurchaseButton_pressed():
	#Make actual transaction
	if upgradeNum == 0:
		global.spendCredits(thisRocket.rocketCost)
		global.buyRocket(thisRocket.rocketName)
		$VBox/Label.text = "\n" + thisRocket.rocketName + "\n\nPurchase complete!"
	else:
		global.spendCredits(thisRocket.upgradeCosts[upgradeNum])
		global.buyRocketUpgrade(thisRocket.rocketName, upgradeNum)
		$VBox/Label.text = "\n" + thisRocket.upgrades[upgradeNum] + "\n\nPurchase complete!"
	
	$VBox/PurchaseButton.hide()
	
	#Visual/audio confirmation for player
	playSound()
	playAnimation()
	emit_signal("purchaseComplete")

#Play upgrade sound
func playSound():
	if global.getSoundOn() == true:
		$AudioStreamPlayer.play()

#Play celebratory animation
func playAnimation():
	#Smaller, rotated copy of upgraded rocket
	var rocketCopy : Node
	rocketCopy = thisRocket.duplicate()
	rocketCopy.get_node("Camera").current = false
	add_child(rocketCopy)
	rocketCopy.hide()
	rocketCopy.scale = Vector2(0.6,0.6)
	rocketCopy.rotation_degrees = 30
	
	#Animation distances
	var yPos = [screenSize.y * 7/10,
		screenSize.y * 7/10 + screenSize.y * 1/10,
		screenSize.y * 7/10 - screenSize.y * 1/10,
		screenSize.y * 7/10 + screenSize.y * 2/10,
		screenSize.y * 7/10 - screenSize.y * 2/10,
		screenSize.y * 7/10 + screenSize.y * 3/10,
		screenSize.y * 7/10 - screenSize.y * 3/10,
		screenSize.y * 7/10,
		screenSize.y * 7/10 + screenSize.y * 1/10,
		screenSize.y * 7/10 - screenSize.y * 1/10,
		screenSize.y * 7/10 + screenSize.y * 4/10,
		screenSize.y * 7/10 - screenSize.y * 4/10,
		screenSize.y * 7/10 + screenSize.y * 5/10]
	
	var tempRocket : Node
	#Rockets fly across screen from each side
	for i in yPos.size():
		tempRocket = rocketCopy.duplicate()
		add_child(tempRocket)
		tempRocket.position = Vector2(-60, yPos[i])
		
		tempRocket.show()
		$Tween.interpolate_property(tempRocket, "position", tempRocket.position, tempRocket.position + Vector2(600,-1039), 1.3, \
			Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.start()
		yield(get_tree().create_timer(.06), "timeout")
	
	rocketCopy.free()

#Back to rocket upgrade screen
func _on_BackButton_pressed():
	hide()
	get_tree().paused = false

#Free rocket when animation complete
func _on_Tween_tween_completed(object, key):
	object.free()
