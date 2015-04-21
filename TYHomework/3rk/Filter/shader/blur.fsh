precision lowp float;

varying highp vec2 textureCoordinate;
uniform  lowp sampler2D videoFrame;

uniform float dimFactor;
uniform vec2 origin;
uniform float radius;
uniform float outerRadius;
uniform float theta;
uniform int blurMode;


void main(void)
{  
     float pixelWidth = 0.027;
     vec2 blurVector = vec2(0.1,0.1);

//    vec4 avgValue = vec4(0.0);
//    vec2 offset = vec2(0.0);
//    
//    avgValue += texture2D(videoFrame, textureCoordinate) * 0.1732272;
//    
//    offset = blurVector * (pixelWidth * 1.4297636);
//    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.2764518;
//    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.2764518;
//    
//    offset = blurVector * (pixelWidth * 3.3407614);
//    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.1124858;
//    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.1124858;
//    
//    offset = blurVector * (pixelWidth * 5.2617311);
//    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.0222258;
//    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.0222258;
//    
//    offset = blurVector * (pixelWidth * 7.1955916);
//    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.0021232;
//    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.0021232;
//    
//    gl_FragColor = avgValue / 0.999800529994501;

    
	vec4 pictureTexel = texture2D(videoFrame, textureCoordinate);
    
    vec4 avgValue = vec4(0.0);
    vec2 offset = vec2(0.0);
    
    avgValue += texture2D(videoFrame, textureCoordinate) * 0.1732272;

    offset = blurVector * (pixelWidth * 1.4297636);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.2764518;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.2764518;

    offset = blurVector * (pixelWidth * 3.3407614);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.1124858;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.1124858;

    offset = blurVector * (pixelWidth * 5.2617311);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.0222258;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.0222258;

    offset = blurVector * (pixelWidth * 7.1955916);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.0021232;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.0021232;

    avgValue = avgValue / 0.999800529994501;
    vec4 blurredTexel = mix(avgValue, vec4(1.0), dimFactor);
    vec4 mask;
    
    float d;
    if (blurMode == 0) {
        vec2 normal = vec2(sin(theta), cos(theta));
        d = abs(dot(	textureCoordinate- origin, normal) / sqrt(dot(normal, normal)));
    } else {
        d = distance(origin,textureCoordinate);
    }
    float b = smoothstep(radius, outerRadius, d);
    if (d < radius) {
        mask.r = 0.0;
        mask.g = 0.0;
        mask.b = 0.0;
        mask.a = 1.0;
    } else {
        mask.r = b;
        mask.g = b;
        mask.b = b;
        mask.a = 1.0;
    }
	gl_FragColor = mix(pictureTexel, blurredTexel, mask);
}




