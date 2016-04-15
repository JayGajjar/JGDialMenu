//
//  JGMenuAnimator.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGMenuAnimator.h"

@implementation JGMenuAnimator

- (id)init {
	self = [super init];
	if (self) {
		self.duration = 0.4;
		self.options = UIViewAnimationOptionCurveEaseIn;
	}
	return self;
}

- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options {
	self = [self init];
	if (self) {
		self.duration = duration;
		self.options = options;
	}
	return self;
}

+ (JGMenuAnimator *)sharedInstantAnimator {
	static JGMenuAnimator *sharedAnimator = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!sharedAnimator) {
			sharedAnimator = [[JGMenuAnimator alloc] initWithDuration:0.0 options:UIViewAnimationOptionCurveLinear];
		}
	});
	return sharedAnimator;
}

- (void)willAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu {
	if ([menu isOpenedOrOpening]) {
		item.hidden = NO;
		item.alpha = 0.0;
		item.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
		item.center = menu.centerPointWhileOpen;
	}
}

- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu {
	item.center = ([menu isOpenedOrOpening]) ? item.layoutLocation : menu.centerPointWhileOpen;
	if ([menu isOpenedOrOpening]) {
		item.alpha = 1.0;
		item.transform = CGAffineTransformIdentity;
	} else {
		item.alpha = 0.0;
		item.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
	}
}

- (void)didAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu finished:(BOOL)finished {
	if (finished && [menu isClosedOrClosing]) {
		item.hidden = YES;
		item.transform = CGAffineTransformIdentity;
	}
}

- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu animated:(BOOL)animated completion:(JGMenuAnimatorCompletionBlock)completion {
	[self willAnimateItem:item atIndex:index inMenu:menu];
	[UIView animateWithDuration:self.duration delay:0.0 options:self.options animations:^{
		[self animateItem:item atIndex:index inMenu:menu];
	} completion:^(BOOL finished){
		[self didAnimateItem:item atIndex:index inMenu:menu finished:finished];
		if (completion) {
			completion(item, index, menu, finished);
		}
	}];
}

@end
