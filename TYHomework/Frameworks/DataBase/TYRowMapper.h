//
//  RSRowMapper.h
//  StoreKit
//
//  Created by closure on 3/21/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;
@protocol TYRowMapper <NSObject>
@required
+ (instancetype)alloc;
- (id)rowMapperWithResultSet:(FMResultSet *)resultSet;
@end

