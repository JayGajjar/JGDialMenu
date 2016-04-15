//
//  JGpringMenuAnimator.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGpringMenuAnimator.h"

@interface JGMenuAnimator ()

- (void)willAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu;
- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu;
- (void)didAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu finished:(BOOL)finished;

@end

@implementation JGpringMenuAnimator

- (id)init {
	self = [super init];
	if (self) {
		self.duration = 0.5;
		self.damping = 0.45;
		self.velocity = 7.5;
	}
	return self;
}

- (id)initWithDamping:(CGFloat)damping velocity:(CGFloat)velocity {
	self = [self init];
	if (self) {
		self.damping = damping;
		self.velocity = velocity;
	}
	return self;
}

- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options damping:(CGFloat)damping velocity:(CGFloat)velocity {
	self = [super initWithDuration:duration options:options];
	if (self) {
		self.damping = damping;
		self.velocity = velocity;
	}
	return self;
}

- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu animated:(BOOL)animated completion:(JGMenuAnimatorCompletionBlock)completion {
	[self willAnimateItem:item atIndex:index inMenu:menu];
    item.transform = CGAffineTransformIdentity;
	[UIView animateWithDuration:self.duration
						  delay:0.0
		 usingSpringWithDamping:self.damping
		  initialSpringVelocity:self.velocity
						options:self.options
					 animations:^{
						 [self animateItem:item atIndex:index inMenu:menu];
					 }
					 completion:^(BOOL finished){
						 [self didAnimateItem:item atIndex:index inMenu:menu finished:finished];
						 if (completion) {
							 completion(item, index, menu, finished);
						 }
					 }];
}

@end
