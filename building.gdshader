shader_type canvas_item;

uniform vec4 aacolor: source_color = vec4(0,1,1,1);
uniform float sleep = 0;
uniform vec4 oldcolor : source_color = vec4(1.0,0.56,0.52,1);
uniform vec4 newcolor : source_color = vec4(0,1,1,1);
uniform vec4 oldcolor1 : source_color;
uniform vec4 newcolor1 : source_color;
uniform vec4 oldcolor2 : source_color;
uniform vec4 newcolor2 : source_color;
uniform vec4 oldcolor3 : source_color;
uniform vec4 newcolor3 : source_color;
uniform vec4 oldcolor4 : source_color;
uniform vec4 newcolor4 : source_color;

uniform vec4 oldcolor5 : source_color;
uniform vec4 newcolor5 : source_color;
uniform vec4 oldcolor6 : source_color;
uniform vec4 newcolor6 : source_color;
uniform vec4 oldcolor7 : source_color;
uniform vec4 newcolor7 : source_color;
uniform vec4 oldcolor8 : source_color;
uniform vec4 newcolor8 : source_color;

vec4 when_eq(vec4 x, vec4 y) {
  return 1.0 - abs(sign(x - y));
}

//vec4 when_lt(vec4 x, vec4 y) {
//  return max(sign(y - x), 0.0);
//}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE,UV);
	
	COLOR = vec4(0);
	COLOR = newcolor1 * when_lt(distance(color,oldcolor1),0.01);
	COLOR += newcolor2 * when_lt(distance(color,oldcolor2),0.01);
	COLOR += newcolor3 * when_lt(distance(color,oldcolor3),0.01);
	COLOR += newcolor4 * when_lt(distance(color,oldcolor4),0.01);
	COLOR += newcolor5 * when_lt(distance(color,oldcolor5),0.01);
	COLOR += newcolor6 * when_lt(distance(color,oldcolor6),0.01);
	COLOR += newcolor7 * when_lt(distance(color,oldcolor7),0.01);
	COLOR += newcolor8 * when_lt(distance(color,oldcolor8),0.01);
	vec4 colormod = COLOR;
	COLOR += color * when_lt(distance(vec4(0),colormod),0.1);
	COLOR.rgb = mix(COLOR.rgb, vec3(0,0,0).rgb,sleep);
	//COLOR = color;
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
