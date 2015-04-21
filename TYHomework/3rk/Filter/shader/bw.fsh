precision lowp float;
varying highp vec2 textureCoordinate;

uniform sampler2D videoFrame;
uniform sampler2D light;
uniform sampler2D channel_bw;
uniform sampler2D dark;
mat4 saturateMatrix = mat4(
                           0.3086,     0.3086   ,  0.3086,0,0.6094   ,  0.6094   ,  0.6094,0,
                           0.082,     0.082,     0.082,0,
                           0.0,     0.0,     0.0,     1.0);
void main() {    
    vec4 pic1;
    if (isBlur == 0) {pic1 = texture2D(videoFrame, textureCoordinate);}
    else { pic1 = GC_blur();}
    pic1 = saturateMatrix * pic1;
    vec4 pic0;
    pic0.r = texture2D(channel_bw, vec2(pic1.r, 0.0)).r;
    pic0.g = texture2D(channel_bw, vec2(pic1.g, 0.5)).g;
    pic0.b = texture2D(channel_bw, vec2(pic1.b, 1.0)).b;
    pic0.a = 1.0;
    gl_FragColor = pic0;
}


