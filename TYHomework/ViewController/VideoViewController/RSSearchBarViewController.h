//
//  RSSearchBarViewController.h
//  RSSearchBarTwo
//
//  Created by taoYe on 14/12/8.
//  Copyright (c) 2014年 RenYuXian. All rights reserved.
//

#import <UIKit/UIKit.h>

//设置两种状态 一个是显示打的标签（健身话题相关），另一个就是显示地理位置

typedef NS_ENUM(NSUInteger, RSTagSearchType) {
    RSTagSearchNormal = 1,
    RSTagSearchLocation = 0
};

@class RSTag;
@interface RSSearchBarViewController : UITableViewController
@property (nonatomic, strong) RSTag *currentTag;
@property (nonatomic, assign) RSTagSearchType searchType;
@property (nonatomic, strong) NSString *unwindSegueIdentifier;
@property (nonatomic, assign, getter=isSearchVideoTag) BOOL searchVideoTag;

@end
