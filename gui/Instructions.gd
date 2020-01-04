extends "res://levels/Level.gd"

var currentInstruction : String = "LeftRight"

#Display instruction text
func _on_NextInstruction_pressed():
	showNextInstruction()
func showNextInstruction():
	$GUI/Instruction.show()
	$GUI/NextInstruction.show()
	#Explain left/right movement
	if currentInstruction == "LeftRight":
		$GUI/Arrows/SpecialInstruction.hide()
		$GUI/Arrows/SwitchInstruction.hide()
		$GUI/Instruction.text = "Control your rocket by swiping.\n\nSwipe left/right to move your rocket."
		currentInstruction = "UseAbility"
	#Explain enemies and abilities
	elif currentInstruction == "UseAbility":
		$GUI/Arrows/SpecialInstruction.show()
		$GUI/Arrows/LeftInstruction.hide()
		$GUI/Arrows/RightInstruction.hide()
		$GUI/Instruction.text = "Swipe up to use your rocket's abilities to avoid or destroy enemies."
		#If no enemies, spawn some
		if get_tree().get_nodes_in_group("obstacles").size() == 0:
			var newEnemy
			for i in range(1,4):
				newEnemy = Enemy.instance()
				newEnemy.connect("destroyed", self, "_on_enemy_destroyed") #Receives signal when enemy is destroyed
				newEnemy.position = Vector2((i - 2) * moveDistance, -i * 500 - 700)
				add_child(newEnemy)
		currentInstruction = "AbilityCD"
	elif currentInstruction == "AbilityCD":
		$GUI/Instruction.text = "Green bar shows how long the ability lasts.\n\nRed bar shows how long until you can use it again."
		currentInstruction = "Switch"
	#Explain switching rockets
	elif currentInstruction == "Switch":
		$GUI/Arrows/SwitchInstruction.show()
		$GUI/Arrows/SpecialInstruction.hide()
		$GUI/Instruction.text = "Swipe down to switch between rockets, take advantage of their different abilities and separate cooldowns.\n\nNo rocket can do it alone!"
		currentInstruction = "Scoring"
	#Explain powerups and the goal of the game
	elif currentInstruction == "Scoring":
		$GUI/Arrows/SwitchInstruction.hide()
		$GUI/Arrows/SpecialInstruction.hide()
		$GUI/Instruction.text = "Collecting green power cells, destroying enemies, and preserving your HP increases your score.\n\nEarn credits based on your score at the end of a level.\n\nBuy/upgrade rockets with credits."
		#Spawn powerups
		var newPowerup
		for i in range(1,4):
			newPowerup = Powerup.instance()
			newPowerup.position = Vector2((i - 2) * moveDistance, -i * 500 - 600)
			add_child(newPowerup)
		#If no enemies, spawn some
		if get_tree().get_nodes_in_group("obstacles").size() == 0:
			var newEnemy
			for i in range(1,4):
				newEnemy = Enemy.instance()
				newEnemy.connect("destroyed", self, "_on_enemy_destroyed") #Receives signal when enemy is destroyed
				newEnemy.position = Vector2((i - 2) * moveDistance, -i * 500 - 700)
				add_child(newEnemy)
		currentInstruction = "HP"
	#Explain HP powerups
	elif currentInstruction == "HP":
		$GUI/Arrows/SwitchInstruction.hide()
		$GUI/Arrows/SpecialInstruction.hide()
		$GUI/Instruction.text = "Your rockets share 5HP to start.\n\nHP decreases if you collide with enemies.\n\nHP increases if you collect repair packs."
		#Spawn HP powerups
		var newPowerup
		for i in range(1,4):
			newPowerup = HpPowerup.instance()
			newPowerup.position = Vector2((i - 2) * moveDistance, -i * 500 - 600)
			add_child(newPowerup)
		#If no enemies, spawn some
		if get_tree().get_nodes_in_group("obstacles").size() == 0:
			var newEnemy
			for i in range(1,4):
				newEnemy = Enemy.instance()
				newEnemy.connect("destroyed", self, "_on_enemy_destroyed") #Receives signal when enemy is destroyed
				newEnemy.position = Vector2((i - 2) * moveDistance, -i * 500 - 700)
				add_child(newEnemy)
		currentInstruction = "LeftRight"

#Set up rockets for instruction screen
func _onready():
	initialMousePos = Vector2(0, 0)
	moveDistance = screenSize.x / 3
	score = 0
	
	#Show all rockets
	rockets = global.getAllRockets()
	addRockets()
	
	#GUI
	for item in $GUI/PauseMenu.get_children():
		item.hide()
	$ParallaxBackground.setSpeed(100)
	
	initializeGUI()
	showNextInstruction()
	
	$GUI/BackButton.show()
	$GUI/PauseButton.hide()
	$GUI/DistanceBar.hide()


#Movement inputs, with additional instruction text
func _oninput(event):
	#Saves initial drag point
	if event is InputEventMouseButton and event.is_pressed():
		initialMousePos = event.position
		#Show mouse gesture indicator
		$GUI/MouseStart.position = event.position
		$GUI/MouseStart.show()
		$GUI/MouseStart/MouseStart2.show()
	#Complete action if swipe is complete
	elif event is InputEventMouseButton and !event.is_pressed():
		var mouseDiff = event.position - initialMousePos
		if abs(mouseDiff.x) > abs(mouseDiff.y) + 10:
			#Left swipe
			if mouseDiff.x < -minGestureDist:
				moveLeft(false)
			#Right swipe
			elif mouseDiff.x > minGestureDist:
				moveRight(false)
		elif abs(mouseDiff.y) > abs(mouseDiff.x) + 10:
			#Down swipe
			if mouseDiff.y > minGestureDist:
				switchRocketTrigger(false)
			#Up swipe
			elif mouseDiff.y < -minGestureDist:
				useSpecial(false)
		#Reset state variables
		initialMousePos = Vector2(0, 0)
		$GUI/GestureDescription.text = ""
		$GUI/MouseStart.hide()
		$GUI/MouseStart/MouseStart2.hide()
		$GUI/MouseStart/MouseStart2.position = Vector2(0,0)
		$GUI/MouseStart/MouseStart2.modulate = Color(1,1,1)
		
		#Reset highlight colors
		for n in $GUI/Arrows.get_children():
			n.modulate = Color(1,1,1)
	#Preview which action will happen upon mouse-up
	elif event is InputEventMouseMotion and initialMousePos != Vector2(0, 0):
		#Reset highlight colors
		for n in $GUI/Arrows.get_children():
			n.modulate = Color(1,1,1)
		
		var mouseDiff = event.position - initialMousePos
		#Update indicator
		$GUI/MouseStart/MouseStart2.position = mouseDiff.normalized() * clamp(mouseDiff.length() / 5, 0, 10)
		$GUI/GestureDescription.text = ""
		$GUI/MouseStart/MouseStart2.modulate = Color(1,1,1)
		#Left/right swipe
		if abs(mouseDiff.x) > abs(mouseDiff.y) + 10:
			if mouseDiff.x < -minGestureDist:
				moveLeft(true)
			elif mouseDiff.x > minGestureDist:
				moveRight(true)
		#Down swipe
		elif abs(mouseDiff.y) > abs(mouseDiff.x) + 10:
			#Down swipe
			if mouseDiff.y > minGestureDist:
				switchRocketTrigger(true)
			#Up swipe
			elif mouseDiff.y < -minGestureDist:
				useSpecial(true)
	#Keyboard controls for rocket movement
	elif Input.is_action_pressed("ui_left"):
		moveLeft(false)
	elif Input.is_action_pressed("ui_right"):
		moveRight(false)
	elif Input.is_action_just_pressed("ui_down"):
		switchRocketTrigger(false)
	elif Input.is_action_pressed("ui_up"):
		useSpecial(false)
	#Quit level
	elif Input.is_action_pressed("ui_cancel"):
		if $GUI/BackButton.visible == true:
			_on_BackButton_pressed()
		else:
			quitScene()
	#Pause/unpause game
	elif Input.is_action_pressed("ui_pause"):
		_on_PauseButton_pressed()
func moveLeft(preview):
	if !preview:
		rockets[0].moveLeft()
	else:
		$GUI/GestureDescription.text = "Move left"
		$GUI/Arrows/LeftInstruction.modulate = Color(0,0,1)
		$GUI/MouseStart/MouseStart2.modulate = Color(0,0,1)
func moveRight(preview):
	if !preview:
		rockets[0].moveRight()
	else:
		$GUI/GestureDescription.text = "Move right"
		$GUI/Arrows/RightInstruction.modulate = Color(0,0,1)
		$GUI/MouseStart/MouseStart2.modulate = Color(0,0,1)
func switchRocketTrigger(preview):
	if !preview:
		switchRockets(1)
	else:
		$GUI/GestureDescription.text = "Switch rockets"
		$GUI/Arrows/SwitchInstruction.modulate = Color(1,0,0)
		$GUI/MouseStart/MouseStart2.modulate = Color(1,0,0)
func useSpecial(preview):
	if !preview:
		rockets[0].useSpecial()
	elif rockets[0].specialAvailable == true:
		$GUI/GestureDescription.text = rockets[0].specialDesc
		$GUI/Arrows/SpecialInstruction.modulate = Color(0,1,0)
		$GUI/MouseStart/MouseStart2.modulate = Color(0,1,0)

#Override movement from Rocket class
func _callprocess(delta):
	pass

#Back to main menu
func quitScene():
	_on_BackButton_pressed()

