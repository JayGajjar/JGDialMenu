//
//  JGCircleLayout.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JGMenu.h"

@interface JGCircleLayout : NSObject <JGMenuLayout>

@property (readwrite, assign, nonatomic) CGFloat radius;
@property (readwrite, assign, nonatomic) CGFloat arc; // negative for counter-clockwise
@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat minDistance; // 0.0 for non-layered
@property (readwrite, assign, nonatomic) BOOL uniformOuterLayer;

- (id)initWithRadius:(CGFloat)radius arc:(CGFloat)arc angle:(CGFloat)angle minDistance:(CGFloat)minDistance;
+ (NSArray *)layoutItems:(NSArray *)items inArc:(CGFloat)arc fromAngle:(CGFloat)angle withRadius:(CGFloat)radius aroundCenterPoint:(CGPoint)centerPoint inMenu:(JGMenu *)menu ;
+ (CGFloat)arcForFullCircleWithItemCount:(NSUInteger)itemCount ;
+ (CGFloat)angleForItemAtIndex:(NSUInteger)itemIndex ofCount:(NSUInteger)itemCount inArc:(CGFloat)arc startintAtAngle:(CGFloat)angle ;
@end
