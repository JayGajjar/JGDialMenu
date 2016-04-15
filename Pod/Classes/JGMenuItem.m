//
//  JGMenuItem.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGMenuItem.h"

@implementation JGMenuItem

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.layoutLocation = self.center;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		self.layoutLocation = self.center;
	}
	return self;
}

- (id)initWithContentView:(UIView *)contentView representedObject:(id)representedObject {
	self = [self initWithFrame:contentView.frame];
	if (self) {
		self.contentView = contentView;
		self.representedObject = representedObject;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveAngleChangeNotification:)
                                                     name:@"AngleChangeNotification"
                                                   object:nil];
	}
	return self;
}

- (void)setContentView:(UIView *)contentView {
	[_contentView removeFromSuperview];
	_contentView = contentView;
	self.bounds = contentView.bounds;
	[self addSubview:contentView];
}

- (void)setLayoutLocation:(CGPoint)layoutLocation {
	_layoutLocation = layoutLocation;
}

- (void)layoutSubviews {
	self.contentView.frame = self.bounds;
}

- (void) receiveAngleChangeNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"AngleChangeNotification"]){
//        NSLog (@"Successfully received the test notification!");
        NSNumber *angle = notification.object;
        [[self layer] setTransform:CATransform3DMakeRotation(-angle.doubleValue, 0, 0, 1)];

    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AngleChangeNotification" object:nil];
}
@end
