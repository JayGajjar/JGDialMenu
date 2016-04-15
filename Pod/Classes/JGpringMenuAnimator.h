//
//  JGpringMenuAnimator.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGMenuAnimator.h"

@interface JGpringMenuAnimator : JGMenuAnimator

@property (readwrite, assign, nonatomic) CGFloat damping;
@property (readwrite, assign, nonatomic) CGFloat velocity;

- (id)initWithDamping:(CGFloat)damping velocity:(CGFloat)velocity;
- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options damping:(CGFloat)damping velocity:(CGFloat)velocity;

@end
