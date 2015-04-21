precision lowp float;
varying highp vec2 textureCoordinate;

uniform sampler2D videoFrame;
uniform sampler2D light1;
uniform sampler2D channel_1949;
uniform sampler2D dark1;

mat4 brightMatrix = mat4(
                         1.1,     0.0,     0.0,     0.0,
                         0.0,     1.1,     0.0,     0.0,
                         0.0,     0.0,     1.1,     0.0,
                         0.0,     0.0,     0.0,     1.0);

mat4 saturateMatrix = mat4(
                           0.6543,     0.1543 ,    0.1543,0,
                           0.3047,     0.8047,     0.3047,0,
                           0.041,     0.041,     0.541,0,
                           0.03,     0.01,     0.0,     1.0);

void main() {	
	vec4 pic1;
    if (isBlur == 0) {
        pic1 = texture2D(videoFrame, textureCoordinate);
     }
    else 
    { 
        pic1 = GC_blur();

    }

    vec3 pic2 = texture2D(light1, textureCoordinate).rgb;
    pic1.r = texture2D(dark1, vec2(pic2.r, pic1.r)).r;
    pic1.g = texture2D(dark1, vec2(pic2.g, pic1.g)).g;
    pic1.b = texture2D(dark1, vec2(pic2.b, pic1.b)).b;
    
	pic1 = saturateMatrix * pic1;
	pic1 = brightMatrix * pic1;
    
    vec4 pic0;
    pic0.r = texture2D(channel_1949, vec2(pic1.r, 0.0)).r;
    pic0.g = texture2D(channel_1949, vec2(pic1.g, 0.5)).g;
    pic0.b = texture2D(channel_1949, vec2(pic1.b, 1.0)).b;
    pic0.a = 1.0;
    
	gl_FragColor = pic0;
}