//
//  JGMenuItem.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGMenuItem : UIView

@property (readwrite, strong, nonatomic) UIView *contentView;
@property (readwrite, strong, nonatomic) id representedObject;
@property (readwrite, assign, nonatomic) CGPoint layoutLocation;

- (id)initWithContentView:(UIView *)contentView representedObject:(id)representedObject;

@end
