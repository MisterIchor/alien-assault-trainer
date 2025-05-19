class_name TransitionListenerInput
extends TransitionListener

## Listens for [InputEvent]s from [Input], with support for [InputEvent] combinations and check.
##
## [TransitionListenerInput] listens for events using a method from [Input] depending on what
## [member event_listener_type] is set to. Events are grouped into [PackedStringArray]s, which are also within an 
## [Array]. 
##[br][br]
## When [TransitionListenerInput] checks for a transition, it iterates though each [PackedStringArray] 
## to see if any of the events within are being pressed/released. [signal TransitionListener.check_success] will be emitted 
## if at least one event from each [PackedStringArray] returns true.
##[br][br]
## For example, there are two events that can be pressed: [code]"foo"[/code] and [code]"bar"[/code].
##[br] 
## Assume [member event_listener_type] is set to [enum EventListenerType].PRESSED.
##[br][br]
## If:
##[br]
## [code][["foo"]][/code] is passed to [method Object.new], then [signal TransitionListener.check_success] will be emitted 
## if event [code]"foo"[/code] is being pressed.
##[br]
## [code][["foo", "bar"]][/code] is passed to [method Object.new], then [signal TransitionListener.check_success] will be emitted 
## if events [code]"foo"[/code] [b]or[/b] [code]"bar"[/code] are being pressed.
##[br]
## [code][["foo"], ["bar"]][/code] is passed to [method Object.new], then [signal TransitionListener.check_success] will be emitted 
## if events [code]"foo"[/code] [b]and[/b] [code]"bar"[/code] are being pressed.
##[br][br]
## This allows for complex state transitions i.e. transitioning from an idle state to a moving state when
## pressing any movement events, or to a sprinting state if any movement events are pressed in tandem with
## a sprint event.

enum EventListenerType {
	## [method TransitionListener._check] will use the value returned from 
	## [method Input.is_action_pressed] when checking each event.
	PRESSED, 
	## [method TransitionListener._check] will use the value opposite of the one returned
	## from [method Input.is_action_pressed] when checking each event.
	NOT_PRESSED
}

## Events that this [TransitionListenerInput] is listen for.
var events_to_listen_for: Array[PackedStringArray] = []
## Determines what method from [Input] will be used within [method TransitionListener._check].
## Set [member InputListenerType] for more.
var event_listener_type: EventListenerType = EventListenerType.PRESSED



func _init(input_group: Array[PackedStringArray], listener_type: EventListenerType) -> void:
	events_to_listen_for = input_group
	event_listener_type = listener_type
	call_check_every_process_frame = true



func _check() -> void:
	var input_success: PackedInt32Array = []
	input_success.resize(events_to_listen_for.size())
	input_success.fill(0)
	
	for i: int in events_to_listen_for.size():
		var input_group: PackedStringArray = events_to_listen_for[i]
		
		for input: String in input_group:
			match event_listener_type:
				EventListenerType.PRESSED:
					if Input.is_action_pressed(input):
						input_success[i] = 1
						break
				EventListenerType.NOT_PRESSED:
					if not Input.is_action_pressed(input):
						input_success[i] = 1
						break
	
	for i in input_success:
		if not i:
			return
	
	check_success.emit()
