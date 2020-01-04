extends Node

var selectedScene : String

var soundOn : Texture = preload("res://images/Sound.png")
var soundOff : Texture = preload("res://images/SoundOff.png")
var musicOn : Texture = preload("res://images/MusicIcon.png")
var musicOff : Texture = preload("res://images/MusicOffIcon.png")

func _ready():
	#Returns to this scene after level is done
	global.returnScene = self.get_filename()
	
	$ParallaxBackground.setSpeed(-50)
	
	#Figure out if sound on/off
	if global.getSoundOn() == false:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Sound.texture_normal = soundOff
	else:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Sound.texture_normal = soundOn
	if global.getMusicOn() == false:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Music.texture_normal = musicOff
	else:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Music.texture_normal = musicOn
		if get_node("/root/Music").is_playing() == false:
			get_node("/root/Music").play()
	
	#Allow endless option if last level is at least 1 star
	if global.getScore(12) >= 1:
		$MarginContainer/VBoxContainer/PlayEndless.show()


#Show level select scene
func _on_Play_pressed():
	selectedScene = "res://gui/LevelSelect.tscn"
	switchScene(false)

#Show instructions scene
func _on_Instructions_pressed():
	selectedScene = "res://gui/Instructions.tscn"
	switchScene(false)

#Show rocket upgrade scene
func _on_Rockets_pressed():
	selectedScene = "res://gui/RocketGuide.tscn"
	switchScene(false)

#Show credits scene
func _on_Credits_pressed():
	selectedScene = "res://gui/Credits.tscn"
	switchScene(false)

#Toggle sound/music
func _on_Sound_pressed():
	global.toggleSound()
	if global.getSoundOn() == false:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Sound.texture_normal = soundOff
	else:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Sound.texture_normal = soundOn
func _on_Music_pressed():
	global.toggleMusic()
	if global.getMusicOn() == false:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Music.texture_normal = musicOff
	else:
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Music.texture_normal = musicOn

func switchScene(tweenComplete):
	if false:
		$Tween.interpolate_property($HighlightRect, "rect_position:y", $HighlightRect.rect_position.y, $HighlightRect.rect_position.y + $HighlightRect.rect_size.y / 2, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.interpolate_property($HighlightRect, "rect_size:y", $HighlightRect.rect_size.y, 1, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.interpolate_property($HighlightRect, "rect_position:x", $HighlightRect.rect_position.x, $HighlightRect.rect_position.x - (700 - $HighlightRect.rect_size.x) / 2, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.interpolate_property($HighlightRect, "rect_size:x", $HighlightRect.rect_size.x, 700, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	else:
		get_tree().change_scene(selectedScene)
		queue_free()

#Switch scene after animation
func _on_Tween_tween_completed(object, key):
	switchScene(true)


#Play "endless" level
func _on_PlayEndless_pressed():
	#Returns to this scene after level is done
	global.returnScene = self.get_filename()
	
	#Loads level based on button pressed
	var next_level_resource
	next_level_resource = load("res://levels/BossLevel.tscn")
	var next_level = next_level_resource.instance()
	next_level.levelIndex = 13
	next_level.setupLevel()
	get_tree().get_root().add_child(next_level)
	
	queue_free()
