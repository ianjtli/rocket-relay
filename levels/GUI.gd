extends CanvasLayer

func _ready():
	pass

func _input(event):
	#Quit level
	if Input.is_action_just_pressed("ui_cancel"):
		if $BackButton.visible == true:
			get_parent()._on_Back_pressed()
		else:
			get_parent().quitScene()
	#Pause/unpause game
	elif Input.is_action_just_pressed("ui_pause"):
		get_parent()._on_PauseButton_pressed()
		get_tree().set_input_as_handled()