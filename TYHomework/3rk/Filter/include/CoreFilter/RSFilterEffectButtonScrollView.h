//
//  PintuScrollButtonView.h
//  Weico
//
//  Created by zhoukai on 11-5-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define  NOTIFYNEWAPP @"openlinkinapp"
@protocol ScrollButtonDelegate;

@interface RSFilterEffectButtonScrollView : UIScrollView {
    NSMutableArray  *dicConfig;
    BOOL isaftertake;
    int  countOfImage;
    int  selectIndex;
    int  lastIndex;
    int  filterIndex;
    CGRect theRect;
    UIImageView *selectView;
    __weak id<ScrollButtonDelegate> tapdelegate;
    CGFloat  topHeight,downHeight,leftWeight,rightWeight;
    NSString *theImageName;
    BOOL isSquare;
    BOOL isAdjustImage ;
    UIView *__unsafe_unretained oriView;
//    UIButton *NormalButton;
//    UILabel *NormalLable;
}
@property(nonatomic,unsafe_unretained)UIView *oriView;
@property(nonatomic,assign)BOOL isSquare,isAdjustImage;
@property(nonatomic,strong)   NSString *theImageName;
@property(nonatomic,assign)  CGRect theRect;
@property(nonatomic,assign) BOOL isaftertake;
@property(nonatomic,assign)  int  filterIndex,selectIndex;
@property(nonatomic,strong) UIImageView *selectView;
@property(nonatomic,strong) NSMutableArray  *dicConfig;
@property(nonatomic,weak) IBOutlet id<ScrollButtonDelegate> tapdelegate;
- (instancetype)initWithFrame:(CGRect)frame withCount:(int)count andScrollTo:(float)scrollx;
-(void)changeFrameView;
-(void)makeLongSquare;
-(void)makeScrollViewWith:(NSArray*)array andContStart:(int)contStart  andScrollx:(float)scrollx;
@end
@protocol ScrollButtonDelegate
@optional
-(void)makeBoxViewByImage:(UIImage*)image;
-(void)filterChangedWith:(int)filterType;
-(void)finisheAdjust;
@end
