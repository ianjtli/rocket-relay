extends "res://levels/Level.gd"

func _onready():
	initialMousePos = Vector2(0, 0)
	
	#All rockets
	rockets = global.getAllRockets()
	addRockets()
	
	#GUI
	for item in $GUI.get_children():
		item.hide()
	$GUI/BackButton.show()
	
	$GUI/Menu.show()
	$GUI/GestureDescription.show()
	$GUI/RocketQueue.show()
	$GUI/Credits.show()
	$GUI/Credits.text = "Credits: " + str(global.getCredits())
	
	$ParallaxBackground.setSpeed(100)
	
	updateRocketGUI()


#Update screen for rocket description and upgrades
func updateRocketGUI():
	$GUI/Arrows.hide()
	#Reset rocket settings
	rockets[0].setDefaults()
	$GUI/Menu/MenuVBox/RocketName.text = rockets[0].rocketName
	$GUI/Menu/MenuVBox/RocketDesc.text = rockets[0].rocketDesc + "\n\n" + "Ability: " + rockets[0].specialDesc
	$GUI/Credits.text = "Credits: " + str(global.getCredits())
	
	#Populate upgrade buttons
	for i in range(1,4):
		$GUI/Menu/MenuVBox/MenuHBox.get_node("UpgradeButtons/Upgrade" + str(i)).disabled = false
		$GUI/Menu/MenuVBox/MenuHBox.get_node("UpgradeLabels/Upgrade" + str(i)).text = rockets[0].upgrades[i]
		if global.getRocketList()[rockets[0].rocketName + "Upgrade" + str(i)] == 1:
			if global.getRocketList()[rockets[0].rocketName + "Upgrade" + str(i) + "Active"] == 1:
				$GUI/Menu/MenuVBox/MenuHBox.get_node("UpgradeButtons/Upgrade" + str(i)).text = "Deactivate"
			else:
				$GUI/Menu/MenuVBox/MenuHBox.get_node("UpgradeButtons/Upgrade" + str(i)).text = "Activate"
		else:
			$GUI/Menu/MenuVBox/MenuHBox.get_node("UpgradeButtons/Upgrade" + str(i)).text = str(rockets[0].upgradeCosts[i]) + " credits"
	
	#If player already purchased rockets
	if global.getRocketList()[rockets[0].rocketName] == 1:
		if global.getRocketList()[rockets[0].rocketName + " Active"] == 1:
			$GUI/Menu/MenuVBox/BuyRocket.text = "Remove rocket from lineup"
		else:
			$GUI/Menu/MenuVBox/BuyRocket.text = "Add rocket to lineup"
	else:
		$GUI/Menu/MenuVBox/BuyRocket.show()
		$GUI/Menu/MenuVBox/BuyRocket.text = "Purchase rocket: " + str(rockets[0].rocketCost) + " credits"
		$GUI/Menu/MenuVBox/MenuHBox/UpgradeButtons/Upgrade1.disabled = true
		$GUI/Menu/MenuVBox/MenuHBox/UpgradeButtons/Upgrade2.disabled = true
		$GUI/Menu/MenuVBox/MenuHBox/UpgradeButtons/Upgrade3.disabled = true


func _on_BuyRocket_pressed():
	#Purchase rocket
	if global.getRocketList()[rockets[0].rocketName] == 0:
		if global.getCredits() >= rockets[0].rocketCost:
			$GUI/UpgradeConfirmation.showUpgrade(rockets[0],0)
		else:
			showMsgBox("Error","Not enough credits")
	#Add/remove rocket from queue
	else:
		#Must have at least 2 rockets active
		if global.getActiveRockets().size() > 2 or $GUI/Menu/MenuVBox/BuyRocket.text == "Add rocket to lineup":
			global.toggleRocket(rockets[0].rocketName)
		else:
			showMsgBox("Error","Must have at least 2 rockets\nin your lineup")
	updateRocketGUI()

#Purchase upgrade
func _on_Upgrade1_pressed():
	buyUpgrade(1)
func _on_Upgrade2_pressed():
	buyUpgrade(2)
func _on_Upgrade3_pressed():
	buyUpgrade(3)
func buyUpgrade(upgradeNum):
	#If upgrade already bought, toggle it active/inactive
	if global.getRocketList()[rockets[0].rocketName + "Upgrade" + str(upgradeNum)] == 1:
		global.toggleUpgrade(rockets[0].rocketName + "Upgrade" + str(upgradeNum))
	#Otherwise, try to buy upgrade
	elif global.getCredits() >= rockets[0].upgradeCosts[upgradeNum]:
		$GUI/UpgradeConfirmation.showUpgrade(rockets[0],upgradeNum)
	else:
		showMsgBox("Error","Not enough credits")
	updateRocketGUI()

#Show the message box confirmation or error message 
func showMsgBox(type,msg):
	$GUI/MsgBox.window_title = type
	$GUI/MsgBox.dialog_text = msg
	$GUI/MsgBox.popup_centered()

#Override movement from Level class
func _callprocess(delta):
	pass
#Override hp
func updateHpBar(hpChange):
	pass

#Back to main menu
func quitScene():
	_on_BackButton_pressed()

#Update GUI after purchase complete
func _on_UpgradeConfirmation_purchaseComplete():
	updateRocketGUI()
