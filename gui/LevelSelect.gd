extends Node

export (PackedScene) var LevelButton
var starTexture : Texture = preload("res://images/Star.png")
var starEmptyTexture : Texture = preload("res://images/StarEmpty.png")

const MAX_PAGES : int = 3
var pageNum : int = 1

func _ready():
	$ParallaxBackground.setSpeed(-50)
	
	#Show credits
	$Credits.text = "Credits: " + str(global.getCredits())
	
	#Dynamically populates level buttons and high scores
	var entity
	for i in range(get_tree().get_nodes_in_group("levelbuttons").size()):
		#Update level number for button
		entity = get_tree().get_nodes_in_group("levelbuttons") [i]
		var levelNum : int = (1 + i) + (pageNum - 1) * 4
		entity.get_node("Button").text = "Level " + str(levelNum)
		#Connect new signal to button
		if entity.is_connected("pressed", self, "_on_LevelButton_pressed"):
			entity.disconnect("pressed", self, "_on_LevelButton_pressed")
		entity.connect("pressed", self, "_on_LevelButton_pressed", [levelNum])
		
		#Disable level button if previous level hasn't been beaten
		if levelNum > 1:
			if global.getScore(levelNum - 1) == 0:
				entity.get_node("Button").disabled = true
			else:
				entity.get_node("Button").disabled = false
		#Show stars achieved for the level
		if global.getScore(levelNum) >= 1:
			entity.get_node("Stars/Star1").texture = starTexture
		else:
			entity.get_node("Stars/Star1").texture = starEmptyTexture
		if global.getScore(levelNum) >= 2:
			entity.get_node("Stars/Star2").texture = starTexture
		else:
			entity.get_node("Stars/Star2").texture = starEmptyTexture
		if global.getScore(levelNum) >= 3:
			entity.get_node("Stars/Star3").texture = starTexture
		else:
			entity.get_node("Stars/Star3").texture = starEmptyTexture
	
	#Back button text
	if pageNum == 1:
		$MarginContainer/VBoxContainer/BackButton.text = "Main Menu"
	else:
		$MarginContainer/VBoxContainer/BackButton.text = "Back"
	#No next button if last page
	if pageNum == MAX_PAGES:
		$MarginContainer/VBoxContainer/NextButton.hide()
	else:
		$MarginContainer/VBoxContainer/NextButton.show()

#When level button is pressed
func _on_LevelButton_pressed(levelNum):
	#Returns to this scene after level is done
	global.returnScene = self.get_filename()
	
	#Loads level based on button pressed
	var next_level_resource
	if levelNum % 4 == 0: #Boss levels every 4 levels
		next_level_resource = load("res://levels/BossLevel.tscn")
	else:
		next_level_resource = load("res://levels/StandardLevel.tscn")
	var next_level = next_level_resource.instance()
	next_level.levelIndex = levelNum
	next_level.setupLevel()
	get_tree().get_root().add_child(next_level)
	
	queue_free()

#Back to main menu
func _on_Back_pressed():
	if pageNum == 1:
		get_tree().change_scene("res://gui/MainMenu.tscn")
		queue_free()
	else:
		pageNum -= 1
		_ready()

#To next page of levels
func _on_NextButton_pressed():
	pageNum += 1
	_ready()
