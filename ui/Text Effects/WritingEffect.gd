@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name WritingEffect
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [writing_effect param=2.0]hello[/writing_effect] in text.
var bbcode := "we"


func _process_custom_fx(char_fx: CharFXTransform):
	var duration = char_fx.env.get("duration", 2)
	var t = (char_fx.elapsed_time*30 - char_fx.relative_index) / duration
	var a = clamp(t,0,1)
	if t>=1 and t<1.3:
		char_fx.offset.x = ((7 * (sin((char_fx.elapsed_time)*90)))+3) * (2-t)
	char_fx.color.a = 0 if a<1 else 1
	
