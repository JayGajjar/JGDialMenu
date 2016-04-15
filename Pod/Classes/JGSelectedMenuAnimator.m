//
//  JGSelectedMenuAnimator.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGSelectedMenuAnimator.h"

@interface JGMenuAnimator ()

- (void)willAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu;
- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu;
- (void)didAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu finished:(BOOL)finished;

@end

@implementation JGSelectedMenuAnimator

- (void)didAnimateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu finished:(BOOL)finished {
	[super didAnimateItem:item atIndex:index inMenu:menu finished:finished];
	if (finished) {
		item.alpha = 1.0;
		item.transform = CGAffineTransformIdentity;
	}
}

- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu {
	item.alpha = 0.0;
	item.transform = CGAffineTransformConcat(item.transform, CGAffineTransformMakeScale(2.0, 2.0));
}

@end
