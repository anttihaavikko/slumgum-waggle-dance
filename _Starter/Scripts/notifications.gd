class_name Notifications extends SlidingPanel

@export var label: RichTextLabel
@export var hide_after := 2.0

var queue: Array[String] = []

func add(message: String):
	queue.append(message)
	check_queue()

func show_next():
	if queue.size() == 0: return
	label.text = queue.pop_front()
	toggle()
	await get_tree().create_timer(hide_after).timeout
	toggle()
	await get_tree().create_timer(duration).timeout
	show_next()

func check_queue():
	if not open:
		show_next()
