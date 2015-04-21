//
//  ShaderBuilderUtil.h
//  WeicoCamera
//
//  Created by Kai Zhou on 11-11-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSShaderBuilder : NSObject
{
    NSString *theHead,*theTail,*strBlur,*saturateMatrix;
    NSString *strNineFour,
             *strdiana, 
             *strbw,
             *strindigo,
             *strfuji,
             *strloft,
             *strmoment,
             *strsliver,
             *strtwilight,
             *strviolet,
             *strlondon,
             *strxpro,
             *strnormal,
             *strinstant,
             *strtitleshift,
             *strforest;
}
+(NSString*)makeTheResultStrWith:(NSString*)centerStr;
+(NSString*)getVStr;
+(NSString*)getBigVStr;
+(NSString*)getBigBlurMethod;
+(NSString*)getOutPutBlurMethod;
+(NSString*)getShaderNineFourIsBig:(BOOL)isBig;
+(NSString*)getShaderDianaIsBig:(BOOL)isBig;
+(NSString*)getShaderBWIsBig:(BOOL)isBig;
+(NSString*)getShaderindigoIsBig:(BOOL)isBig;
+(NSString*)getShaderfujiIsBig:(BOOL)isBig;
+(NSString*)getShaderloftIsBig:(BOOL)isBig;
+(NSString*)getShadermomentIsBig:(BOOL)isBig;
+(NSString*)getShaderNormalIsBig:(BOOL)isBig;
+(NSString*)getShadersliverIsBig:(BOOL)isBig;
+(NSString*)getShadertwilightIsBig:(BOOL)isBig;
+(NSString*)getShadervioletIsBig:(BOOL)isBig;
+(NSString*)getShaderlondonIsBig:(BOOL)isBig;
+(NSString*)getShaderxproIsBig:(BOOL)isBig;
+(NSString*)getShaderOldSchoolIsBig:(BOOL)isBig;

+(NSString*)getShaderinstantIsBig:(BOOL)isBig;
+(NSString*)getShadertitleshiftIsBig:(BOOL)isBig;
+(NSString*)getShaderforestIsBig:(BOOL)isBig;
@end
