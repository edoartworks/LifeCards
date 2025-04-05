extends ReferenceRect

var startPos: Vector2
var curPos: Vector2
var swiping = false

var length = 200
var vertical_tolerance = 100


func _process(_delta) :
	if Input.is_action_just_pressed("touch_press"):
		var mouse_pos = get_global_mouse_position()
		if get_global_rect().has_point(mouse_pos) and !swiping:
			swiping = true
			startPos = mouse_pos
			#Debug.log(str("Start Position: ", startPos))
	if Input.is_action_pressed("touch_press"):
		if swiping:
			curPos = get_global_mouse_position()
			if get_global_rect().has_point(curPos):
				if startPos.distance_to(curPos) >= length:
					if abs(startPos.y - curPos.y) <= vertical_tolerance and startPos.x < curPos.x:
						#Debug.log("Right Swipe!")
						SignalBus.card_swipe_right.emit()
						swiping = false
					elif abs(startPos.y - curPos.y) <= vertical_tolerance and startPos.x > curPos.x:
						#Debug.log("Left Swipe!")
						SignalBus.card_swipe_left.emit()
						swiping = false
			else:
				swiping = false
	else:
		swiping = false
