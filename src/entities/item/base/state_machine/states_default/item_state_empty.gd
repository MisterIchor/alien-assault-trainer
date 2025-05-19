extends ItemState

"""
This is an empty state that finishes as soon as it starts, just like you in bed.
Use this script if you don't want an interaction to do anything.

The only exception being the Idle state. That'll create an infinite loop.
I think. I know the way I have this set up it would create a loop.
"""


func _enter() -> void:
	finished.emit()
