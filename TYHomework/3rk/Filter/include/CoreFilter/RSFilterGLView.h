//
//  WeicoGLView.h
//  WeicoCamera
//
//  Created by zhouyuanyuan on 11-11-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/glext.h>
//#import "WeicoCamera.h"
#define FBO_HEIGHT 320
#define FBO_WIDTH 427
#pragma mark need to be change
#define TEXTURENUME 21

FOUNDATION_EXPORT float osType;

typedef NS_ENUM(NSInteger, CameraFace) {
    CAMERA_BACK,
    CAMERA_FRRONT
};

enum {
    UNIFORM_VIDEOFRAME,
    UNIFORM_VIDEOFRAME2,
    UNIFORM_VIDEOFRAME3,
    UNIFORM_VIDEOFRAME4,
    UNIFORM_VIDEOFRAME5,
    UNIFORM_INPUTCOLOR,
    UNIFORM_THRESHOLD,
    UNIFORM_TCOFFSET,
    UNIFORM_ISFRONTCAM,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];
typedef NS_ENUM(NSUInteger, TextureType) {
    T_LIGHT,
    T_LIGHT1,
    T_DARK,
    T_DARK1,
    T_DARK2,
    T_LONDON,
    T_1949,
    T_DIANA,
    T_BW,
    T_INDIGO,
    T_FUJI,
    T_LOFT,
    T_MOMENT,
    T_SLIVER,
    T_TWILIGHT,
    T_VIOLET,
    T_XPRO,
    T_INSTANT,
    T_TITLESHIFT,
    T_LIGHT3,
    T_FOREST
};
typedef NS_ENUM(NSUInteger, FilterType) {
    Filter_CropImage = -2,
    Filter_Original_frame = -2,
    Filter_Original_change = -1,
    Filter_Original=0,
    Filter_london=1,
    Filter_loft=2,
    Filter_indigo=3,
    Filter_1949=4,
    Filter_fuji=5,
    Filter_violet=6,
    Filter_Xpro=7,
    Filter_BW=8,
    Filter_diana=9,
    Filter_twilight=10,
    Filter_sliver=11,
    Filter_moment=12,
    Filter_instant=13,
    Filter_blur=14,
    Filter_titleshift=15,
    Filter_forest=16,
    Filter_oldschool=17,
};



enum {
    BlurClose,
    BlurLine,
    BlurPoint
    
}BlurType;

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    ATTRIB_THRESHOLD,
    ATTRIB_TCOFFSET,
    ATTRIB_ISFRONTCAM,
    UNIFORM_MVP_MATRIX,
    NUM_ATTRIBUTES
};

@interface RSFilterGLView : UIView
{
	GLint backingWidth, backingHeight;
    //新滤镜
    GLuint texture[TEXTURENUME];
    CGFloat touchX,touchY,touchAngle,touchScale,touchScaleSmall,blurMaskAphle;
    
    BOOL isBlur;
    int blurType;
    BOOL isBig;
	EAGLContext *context;
    GLuint  selectProgram
    ,directDisplayProgram
    ,xproProgram
    ,londonProgram
    ,ninefourProgram
    ,dianaProgram
    ,bwProgram
    ,indigoProgram
    ,fujiProgram
    ,loftProgram
    ,momentProgram
    ,sliverProgram
    ,twilightProgram
    ,violetProgram
    ,instantProgram
    ,blurProgram
    ,titleshiftProgram
    ,forestProgram
    ,oldSchoolProgram;
    
	GLuint videoFrameTexture;
    GLuint blurTexture;
    FilterType filterType;
    float theScale;
	/* OpenGL names for the renderbuffer and framebuffers used to render to this view */
	GLuint viewRenderbuffer, viewFramebuffer;
    GLuint sampleBuffer;
	int sizeWidth,sizeHeight;
    int frameHeight,videoH_,videoW_;
	int frameWidth;
    BOOL isProcess;
    UIImage *filterImage;
    
}

@property(nonatomic,strong) UIImage *filterImage;
@property(nonatomic,assign) float theScale;
@property(nonatomic,assign) CGFloat touchX,touchY,touchAngle,touchScale,touchScaleSmall,blurMaskAphle;
@property(nonatomic,assign) BOOL isBlur;
@property(nonatomic,assign) int blurType;
@property(nonatomic,assign) FilterType filterType;
@property(nonatomic,strong)	EAGLContext *context;
- (instancetype)initWithBigFrame:(CGRect)frame ;
- (instancetype)initWithFrame:(CGRect)frame andFilterType:(FilterType)type;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)resetShader;
- (void) swapBuffers;
- (void)initialize:(FilterType)type;
// OpenGL drawing
-(void)setUpBlurTextures;
-(void)drawWithNothing;
- (BOOL)createFramebuffers;
- (void)destroyFramebuffer;
- (BOOL)presentFramebuffer;
- (void)setDisplayFramebuffer;
- (void)setupTextures;
- (void)processViewWithImage:(UIImage*)image andCamType:(FilterType)camType andBlurImage:(UIImage*)blurImage;
- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame andCam:(int)camType;
// OpenGL ES 2.0 setup methods
- (void)loadTextureWithImage:(UIImage *)image intoLocation:(GLuint)location ;
- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type theString:(NSString *)Str;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (void)loadTexture:(NSString *)name intoLocation:(GLuint)locations;

-(UIImage *) glToUIImage ;
- (UIImage*)imageByRenderingViewAtSize:(CGSize)size;
-(UIImage *)snapUIImage;
- (UIImage*)snapshot;
- (UIImage *)getGLScreenshot;
-(UIImage *)drawableToCGImage;
- (UIImage *)flipImageVertically:(UIImage *)originalImage;
@end
