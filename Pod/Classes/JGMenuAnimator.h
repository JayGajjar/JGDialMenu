//
//  JGMenuAnimator.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JGMenu.h"

@interface JGMenuAnimator : NSObject <JGMenuAnimator>

@property (readwrite, assign, nonatomic) NSTimeInterval duration;
@property (readwrite, assign, nonatomic) UIViewAnimationOptions options;

- (id)init;
- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options;

+ (JGMenuAnimator *)sharedInstantAnimator;

- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu animated:(BOOL)animated completion:(JGMenuAnimatorCompletionBlock)completion;

@end
