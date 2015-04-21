//
//  RSOptions.h
//  RSBase
//
//  Created by closure on 10/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "TYObject.h"
#import <UIKit/UIKit.h>

@interface RSOptions : TYObject

#define OPTIONS(name, type, pp, default, description) \
    @property (nonatomic, pp, readonly) type name;

#include "RSOptionDefines.h"

+ (RSOptions *)option;

@end
