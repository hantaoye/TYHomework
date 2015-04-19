//
//  RSRoundImageView.m
//  FITogether
//
//  Created by taoYe on 14/12/23.
//  Copyright (c) 2014年 closure. All rights reserved.
//

#import "TYRoundImageView.h"
#import "UIImage+TY.h"

@interface TYRoundImageView ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIImageView *selectedView;


@end
@implementation TYRoundImageView

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor grayColor];
        _backgroundView.alpha = 0.3;
    }
    return _backgroundView;
}

- (UIImageView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checked"]];
        _selectedView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    }
    return _selectedView;
}


- (void)setupClickCheck {
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClick:)]];
    self.tag = 1;
}

- (void)didClick:(UITapGestureRecognizer *)gesture {
    self.selected = self.tag == 1;
}

- (void)setClickEnable:(BOOL)clickEnable {
    if (clickEnable) {
        [self setupClickCheck];
    } else {
        self.userInteractionEnabled = NO;
        self.selected = NO;
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (selected) {
        [self addSubview:self.backgroundView];
        [self addSubview:self.selectedView];
        _selected = YES;
        
    } else {
        [self.backgroundView removeFromSuperview];
        [self.selectedView removeFromSuperview];
        _selected = NO;
    }
    self.tag = selected ? 0 : 1;
}

- (void)setNoRound:(BOOL)noRound {
    _noRound = noRound;
    if (noRound) {
        [self.layer setCornerRadius:0];
    } else {
        [self setupRoundImageView];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    if (!self.isNoRound) {
        [self setupRoundImageView];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        if (!self.isNoRound) {
            [self setupRoundImageView];
        }
    }
    return self;
}

- (void)setupRoundImageView {
    [self.layer setCornerRadius:(MIN(self.frame.size.height / 2, self.frame.size.width / 2))];
    [self.layer setMasksToBounds:YES];
    [self setClipsToBounds:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isNoRound) {
        [self setupRoundImageView];
    }
    if (self.selected) {
        self.selectedView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        self.backgroundView.frame = self.bounds;
    }
}

@end
