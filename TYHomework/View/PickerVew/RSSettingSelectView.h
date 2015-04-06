//
//  RSSettingSelectView.h
//  FITogether
//
//  Created by taoYe on 14/12/26.
//  Copyright (c) 2014年 closure. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RSSettingSelectView;

@protocol RSSettingSelectViewDelegate <NSObject>
@optional
- (void)didClickCancle;
- (void)didClickDone;
@end

@interface RSSettingSelectView : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (nonatomic, weak) id <RSSettingSelectViewDelegate> delegate;


+ (instancetype)settingSelectViewWithPickViewDataSource:(id<UIPickerViewDataSource>)pickViewDataSource pickViewDelegate:(id<UIPickerViewDelegate>)pickViewDelegate delegate:(id<RSSettingSelectViewDelegate>)delegate;
@end
