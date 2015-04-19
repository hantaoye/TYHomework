//
//  TYView.m
//  drawText
//
//  Created by qingyun on 14-9-26.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "TYDrawView.h"

@interface TYDrawView ()

@property (nonatomic, strong) NSMutableArray *allTouches;
@property (nonatomic, strong) NSMutableArray *touchsPath;
@property (nonatomic, assign) NSInteger red;
@property (nonatomic, assign) NSInteger green;
@property (nonatomic, assign) NSInteger blue;

@end

@implementation TYDrawView

- (NSMutableArray *)allTouches
{
    if (nil == _allTouches) {
        _allTouches = [NSMutableArray array];
    }
    return _allTouches;
}

- (void)changeColorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    self.red = red;
    self.green = green;
    self.blue = blue;
    [self setNeedsDisplay];
}


- (void)clear
{
    [self.touchsPath removeAllObjects];
    [self setNeedsDisplay];
}

- (void)back
{
    [self.touchsPath removeLastObject];
    [self setNeedsDisplay];
}

- (void)save
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"______-----");
    } else {
        NSLog(@"++++++");
    }
}

/*- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor blackColor] set];
    for (NSMutableArray *drawArray in self.allTouches) {
        for (int i = 0; i < drawArray.count; i++) {
            
            CGPoint drawPoint = [drawArray[i] CGPointValue];
            if (i == 0) {
                
                CGContextMoveToPoint(context, drawPoint.x, drawPoint.y);
            } else {
            
                CGContextAddLineToPoint(context, drawPoint.x, drawPoint.y);
            }
            
        }
        CGContextStrokePath(context);
    }
 
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint beganPoint = [touch locationInView:self];
    
    NSMutableArray *linePath = [NSMutableArray array];
    
    [linePath addObject:[NSValue valueWithCGPoint:beganPoint]];
    
    [self.allTouches addObject:linePath];
    
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint movedPoint = [touch locationInView:self];
    
    [[self.allTouches lastObject] addObject:[NSValue valueWithCGPoint:movedPoint]];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}
*/

- (NSMutableArray *)touchsPath
{
    if (nil == _touchsPath) {
        _touchsPath = [NSMutableArray array];
    }
    return _touchsPath;
}


- (void)drawRect:(CGRect)rect
{
    
    [[UIColor colorWithRed:self.red/255.0 green:self.green/255.0 blue:self.blue/255.0 alpha:1] set];
    ;
    for (UIBezierPath *path in self.touchsPath) {
        
        path.lineWidth = 5;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        [path stroke];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    
    [self.touchsPath addObject:path];
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    UIBezierPath *path = [self.touchsPath lastObject];
    [path addLineToPoint:point];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}



@end
