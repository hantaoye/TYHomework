/*
 *  ImageProcess.h
 *  HelloWorld
 *
 *  Created by Lucifer.YU on 1/21/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

typedef struct {
	int red;
	int green;
	int blue;
} RGB;

typedef struct {
	float hue;
	float saturation;
	float brightness;
} HSB;

typedef struct{
    float x;
	float y;
	float z;
}XYZ;

typedef struct {
	int  h;
	int  s;
	int  v;
} HSV;


typedef struct HSL
{
	int h;
	int s;
	int l;
}HSL;


typedef struct IFColorHSL IFColorHSL;

typedef struct{
    double L;
	double a;
	double b;
}Lab;

HSL ConvertRGBToHSL (RGB rgb);

RGB ConvertHSLToRGB (HSL hsl);

HSV ConvertRGBToHSV(RGB rgb);

RGB ConvertHSVToRGB(HSV hsv);
HSB ConvertRGBToHSB(RGB rgb);

RGB ConvertHSBToRGB(HSB hsb);

RGB ConvertHSBToRGB(HSB hsb);

Lab ConvertRGBToLab(RGB rgb);

RGB ConvertLabToRGB(Lab lab);

XYZ ConvertRGBToXYZ(RGB rgb);

RGB ConvertXYZToRGB(XYZ xyz);

XYZ ConvertLabToXYZ(Lab lab);

Lab ConvertXYZToLab(XYZ xyz);