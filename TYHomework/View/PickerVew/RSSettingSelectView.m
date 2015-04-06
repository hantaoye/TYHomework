//
//  RSSettingSelectView.m
//  FITogether
//
//  Created by taoYe on 14/12/26.
//  Copyright (c) 2014年 closure. All rights reserved.
//

#import "RSSettingSelectView.h"

@implementation RSSettingSelectView

+ (instancetype)settingSelectViewWithPickViewDataSource:(id<UIPickerViewDataSource>)pickViewDataSource pickViewDelegate:(id<UIPickerViewDelegate>)pickViewDelegate delegate:(id<RSSettingSelectViewDelegate>)delegate {
    RSSettingSelectView *selectView = [[[NSBundle mainBundle] loadNibNamed:@"RSSettingSelectView" owner:nil options:nil] lastObject];
    selectView.pickView.dataSource = pickViewDataSource;
    selectView.pickView.delegate = pickViewDelegate;
    selectView.delegate = delegate;
    return selectView;
}

- (IBAction)didClickCancle {
    if ([self.delegate respondsToSelector:@selector(didClickCancle)]) {
        [self.delegate didClickCancle];
    }
}
- (IBAction)didClickDone {
    if ([self.delegate respondsToSelector:@selector(didClickDone)]) {
        [self.delegate didClickDone];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pickView.tintColor = [UIColor greenColor];    
}

@end
