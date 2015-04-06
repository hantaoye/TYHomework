//
//  RSMultiImageEditView
//  FITogether
//
//  Created by closure on 03/06/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFilterGLView.h"

@protocol RSImageEditViewDelegate;

@interface RSImageEditView : UIScrollView<UIScrollViewDelegate>
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIScrollView  *contentView;
@property (nonatomic, strong) UIBezierPath *realCellArea;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) id<RSImageEditViewDelegate> tapDelegate;
- (void)setImageViewData:(UIImage *)imageData;
@end

@interface RSMultiImageEditView : RSImageEditView
@property (nonatomic, retain) RSFilterGLView *glView;
@end


@protocol RSImageEditViewDelegate <NSObject>

- (void)tapWithEditView:(RSImageEditView *)sender;

@end