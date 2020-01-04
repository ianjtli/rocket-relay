extends ParallaxBackground

onready var screenSize = get_viewport().get_visible_rect().size

var velocity : Vector2

func _ready():
	#Set background
	$ParallaxLayer/Stars.region_rect.size = Vector2(20000, 20000)
	$ParallaxLayer.motion_mirroring = Vector2(20000, 20000)
	$ParallaxLayer.position = Vector2(screenSize.x / 2, 0)
	velocity = Vector2(0, 250)

func setSpeed(speed):
	velocity = Vector2(0, speed)

#Movement
func _process(delta):
	$ParallaxLayer/Stars.position += delta * velocity