//
//  RSVideoAccess.h
//  FITogether
//
//  Created by closure on 3/13/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYObject.h"
#import "RSVideo.h"

typedef void(^RSVideoAction)(RSVideo *photo, NSError *error);
typedef void(^RSVideosAction)(NSArray *photos, NSError *error);

@interface RSVideoAccess : TYObject
+ (void)create:(RSVideo *)video action:(RSVideoAction)action;
@end
