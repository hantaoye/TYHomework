//
//  RSNavigationController.h
//  FITogether
//
//  Created by closure on 3/15/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <CRNavigationController/CRNavigationController.h>

@interface RSNavigationControllerX : CRNavigationController
@property (strong, nonatomic) IBInspectable UIColor *barTintColor;
@end

@interface RSRegNavigationController : CRNavigationController

@end

@interface RSClassHomeNavigationContorller : UINavigationController
@property (strong, nonatomic) UIColor *barTintColor;
@end
