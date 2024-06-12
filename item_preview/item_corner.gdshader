shader_type canvas_item;

uniform vec3 corner_color : source_color;
uniform vec3 border_color : source_color;
uniform bool no_corner = false;

void fragment() {
	if (COLOR.a == 1.0) {
		if (no_corner) {
			if (COLOR.g == 1.0 || COLOR.b == 1.0) {
				COLOR = vec4(border_color, 1.0);
			} else if (COLOR.r == 1.0) {
				COLOR.a = 0.0;
			}
		} else {
			if (COLOR.r == 1.0 || COLOR.b == 1.0) {
				COLOR = vec4(corner_color, 1.0);
			} else if (COLOR.g == 1.0) {
				COLOR = vec4(border_color, 1.0);
			}
		}
	}
}