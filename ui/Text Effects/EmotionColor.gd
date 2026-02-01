@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name EmotionColor
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [color_effect param=2.0]hello[/color_effect] in text.
var bbcode := "eb"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	
	var vertical_size= char_fx.env.get("vertical_size", 6.0)
	var color = char_fx.env.get("color","white")
	char_fx.offset.y += (vertical_size  * sin((char_fx.elapsed_time + (char_fx.range.x*.3))*5))/2
	char_fx.color= color
	return true
