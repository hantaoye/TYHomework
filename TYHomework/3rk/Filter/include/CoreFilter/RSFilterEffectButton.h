//
//  EffectButton.h
//  ImageProcessing
//
//  Created by zhoukai on 11-2-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum _btnEffects
{   EffButtonFree,
	EffButtonPay,
	EffButtonPaying,
	EffButtonPayed
	
}BtnEffects;
@interface RSFilterEffectButton : UIButton {
    NSString *effectName;
	NSString *effectIcon;
    NSString *effectDes;
	NSMutableArray *effectDic;
    NSString *price;
    NSString *productId;
	int index;
    int filterIndex;
    NSString *effectNameEn;
}
@property(nonatomic,assign)    int filterIndex;
@property(nonatomic,strong) NSString *productId;
@property(nonatomic,strong) NSString *price;
@property(nonatomic,strong) NSString *effectDes;
@property(nonatomic,assign) int index;
@property(nonatomic,assign) int actionType;
@property(nonatomic,strong) NSString *effectName;
@property(nonatomic,strong) NSString *effectNameEn;
@property(nonatomic,strong) NSString *effectIcon;
@property(nonatomic,strong) NSMutableArray *effectDic;
@end
