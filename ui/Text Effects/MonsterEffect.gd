@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name MonsterEffect
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [monster_effect param=2.0]hello[/monster_effect] in text.
var bbcode := "me"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.offset.y += (sin((char_fx.elapsed_time*.7 + (char_fx.range.x))))
	char_fx.offset.x += (cos((char_fx.elapsed_time*1 + (char_fx.range.x))))/7
	return true
