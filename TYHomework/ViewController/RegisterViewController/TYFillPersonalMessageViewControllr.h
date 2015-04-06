//
//  RSFillPersonalMessageViewControllr.h
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TYFillPersonalMessageViewControllrDelegate <NSObject>
@optional
- (void)updatePersonalMessage:(NSString *)message;

@end

@interface TYFillPersonalMessageViewControllr : UITableViewController
@property (nonatomic, weak) id<TYFillPersonalMessageViewControllrDelegate> delegate;

@end
