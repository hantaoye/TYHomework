//
//  TYNote.h
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@class TYAccount;
@interface TYNote : TYObject <NSCoding>

@property (assign, nonatomic) NSInteger ID;

@property (copy, nonatomic) NSString *desc;

@property (copy, nonatomic) NSString *title;

@property (copy, nonatomic) NSString *timestamp;

@property (copy, nonatomic) NSString *videopath;

@property (copy, nonatomic) NSString *imageURL;

@property (copy, nonatomic) NSString *drawImageURL;

@property (copy, nonatomic) NSString *audioURL;

@property (weak, nonatomic) TYAccount *user;


@end
