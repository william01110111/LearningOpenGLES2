attribute vec4 a_Position;

varying lowp vec2 frag_TexCoord;

void main(void) {
    gl_Position = a_Position;
	frag_TexCoord = a_Position.xy;
}
