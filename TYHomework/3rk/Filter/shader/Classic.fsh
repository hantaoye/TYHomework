


uniform lowp sampler2D videoFrame;
uniform sampler2D light;
uniform sampler2D channel_classic;
uniform sampler2D dark;
mat4 saturateMatrix = mat4(
0.86172,0.06172,0.06172,0.0,
0.12188,0.92188,0.12188,0.0,
0.0164,0.0164,0.8164,0.0,
0.0,0.0,0.0,1.0);

void main() {   
    vec4 pic1;
    if (isBlur == 0) {pic1 = texture2D(videoFrame, textureCoordinate);}
    else { pic1 = GC_blur();}
    pic1 = saturateMatrix * pic1;
    vec3 pic2 = texture2D(light, textureCoordinate).rgb;
    pic1.r = texture2D(dark, vec2(pic2.r, pic1.r)).r;
    pic1.g = texture2D(dark, vec2(pic2.g, pic1.g)).g;
    pic1.b = texture2D(dark, vec2(pic2.b, pic1.b)).b;
    vec4 pic0;
    pic0.r = texture2D(channel_classic, vec2(pic1.r, 0.0)).r;
    pic0.g = texture2D(channel_classic, vec2(pic1.g, 0.5)).g;
    pic0.b = texture2D(channel_classic, vec2(pic1.b, 1.0)).b;
    pic0.a = 1.0;
    gl_FragColor = pic0;
}


vec4 GC_blur( void )
{   float pixelWidth = 0.05;
    vec2 blurVector = vec2(0.05,0.05);
    vec2 theVec = vec2(textureCoordinate.x*wscaleh,textureCoordinate.y);
    vec4 pictureTexel = texture2D(videoFrame, textureCoordinate);
    vec4 avgValue = vec4(0.0);
    vec2 offset = vec2(0.0);
    avgValue += texture2D(videoFrame, textureCoordinate) * 0.1732272;
    avgValue += texture2D(videoFrame, textureCoordinate) * 0.2099696;
    offset = blurVector * (pixelWidth * 1.3975911);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.3034684;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.3034684;
    offset = blurVector * (pixelWidth * 3.2749744);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.0832605;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.0832605;
    offset = blurVector * (pixelWidth * 5.1789400);
    avgValue += texture2D(videoFrame, textureCoordinate - offset) * 0.0080166;
    avgValue += texture2D(videoFrame, textureCoordinate + offset) * 0.0080166;
    gl_FragColor = avgValue / 0.9994606076195;
    vec4 blurredTexel = mix(avgValue, vec4(1.0), dimFactor);
    vec4 mask;
    float d;
    if (blurMode == 0) {
        vec2 normal = vec2(sin(theta), cos(theta));
        d = abs(dot(theVec- origin, normal) / sqrt(dot(normal, normal)));
    } else {
        d = distance(origin,theVec);
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
    return  mix(pictureTexel, blurredTexel ,mask);//blurredTexel
}
