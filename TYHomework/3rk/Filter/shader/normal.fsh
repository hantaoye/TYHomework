precision lowp float;
varying highp vec2 textureCoordinate;
uniform sampler2D videoFrame;
uniform sampler2D light;
uniform sampler2D channel;
uniform sampler2D dark;
void main() {	
    vec4 pic0 = texture2D(videoFrame, textureCoordinate);
    gl_FragColor = pic0;
}