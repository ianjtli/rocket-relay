extends Node2D

signal completed

var playing : bool = false

func _ready():
	$AnimatedSprite.hide()

func start():
	#Play explosion animation
	$AnimatedSprite.show()
	$AnimatedSprite.play()
	
	#Play explosion sound if sound is on
	if global.getSoundOn() == true:
		$AudioStreamPlayer2D.play()
	playing = true

func _on_AnimatedSprite_animation_finished():
	playing = false
	$AnimatedSprite.frame = 0
	$AnimatedSprite.hide()
	emit_signal("completed")
