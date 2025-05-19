extends EntitySetup

## Setup script for [Item] as part of [ItemTemplate].
##
## When [member Item.template] is set, it will look at [member ItemTemplate.item_setup] and call 
## [method ItemSetup._setup()]. It is expect for another script to extend [ItemSetup] to overwrite 
## [method ItemSetup._setup()] and customize the setup process. It also contains a list of states to
## intialize during the setup process.
##[br][br]
## In addition, it also provides a method of exporting variables through [member configurable_values]
## in which values can be writen to and passed on to [member ItemTemplate.configurable_values]. See 
## [member configurable_values] for more.


## The [Item] that this script is targeting. Set when [member Item.template] is set.
var item: Item = null
## A [Dictionary] consisting of a list of [String] : [Variant] pairs. The string is the name of
## a variable initialized within a script that extends [ItemSetup] that can be customize through 
## [member ItemTemplate.configurable_values], while the variant is the default value that will be initialized.
##[br][br]
## To add to [member configurable_values] simply modify it as if any other [Dictionary]
var configurable_values: Dictionary[String, Variant] = {}
## A [Dictionary] containing a list of [String] : [Script] pairs, where the string is the name of the state
## and the script is the [ItemState] script. When [member Item.template] is set, states are intialized within
## [ItemStateMachine] before [method _setup] is called.
##[br][br]
## By default, [member states] is initialized with the three required states: idle, primary, and 
## secondary. To replace the default states with custom states and even add new states, modify the 
## dictionary within [method Object.init].
##[br][br]
## [b]Note:[/b] If you want a state to do nothing, use [i]../state_machine/states_default/item_state_empty.gd[/i].
## [b]Do not set the idle state to ../state_machine/states_default/item_state_empty.gd[/b], however, as it 
## will cause the program to hang.
var states: Dictionary[String, Script] = {
	idle = load("res://src/entities/item/base/state_machine/item_state.gd"),
	primary = load("res://src/entities/item/base/state_machine/states_default/item_state_empty.gd"),
	secondary = load("res://src/entities/item/base/state_machine/states_default/item_state_empty.gd")
}



func _init() -> void:
	return


## Called by [Item] when [member Item.template] is set after [member states] are initialized
## within [ItemStateMachine]. Overwrite this method to customize the setup of an item.
func _setup() -> void:
	return
