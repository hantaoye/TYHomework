//
//  RSOptions.m
//  RSBase
//
//  Created by closure on 10/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RSOptions.h"

@interface RSOptions() {
    @private
#define OPTIONS(name, type, pp, default, description) \
    type _##name;
    
#include "RSOptionDefines.h"
}

@end

@implementation RSOptions
+ (RSOptions *)option {
    static RSOptions *opts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        opts = [[RSOptions alloc] init];
    });
    return opts;
}

- (instancetype)init {
    if (self = [super init]) {
//#define OPTIONS(name, type, pp, default, description) \
//_##name = default;
//        
//#include "RSOptionDefines.h"
    }
    
    return self;
#undef OPTIONS
}

#define OPTIONS(name, type, pp, default, description) \
- (type)name { \
    return default;\
}

#define STR_OPTIONS(name, type, pp, default, description) \
- (type)name { \
    return NSLocalizedString(default, "");\
}

#include "RSOptionDefines.h"

#undef STR_OPTIONS
#undef OPTIONS

@end
