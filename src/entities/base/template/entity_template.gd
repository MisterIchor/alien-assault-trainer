@tool
class_name EntityInitializer
extends TargetInitializer

## The [Attributes] that should be loaded when initializing the [member target].
var _default_attributes: Array = []
## The primary tags for this [EntityInitializer]. These tags will be added to every
## [Entity] that uses this template for initialization.
var _primary_tags: PackedStringArray = []
## Additional [Attributes] that should be loaded in addition to [member _default_attributes] when
## initializing the [member target].
@export var additional_attributes: Array = []
## The secondary tags that are unique to this [EntityInitializer].
@export var secondary_tags: PackedStringArray = []
## The [EntityState]s that are added to [member target] upon initialization.
@export var states: Array[EntityState] = []
