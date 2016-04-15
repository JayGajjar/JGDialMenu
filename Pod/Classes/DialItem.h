//
//  DialItem.h
//  JGDialMenu
//
//  Created by Jay on 10/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGMenuItem.h"

@interface DialItem : JGMenuItem {
    NSString *titleStr;
    UIImage *image;

}

@property (readwrite, strong, nonatomic) UIImageView *imageView;
@property (readwrite, strong, nonatomic) UILabel *title;

-(instancetype)initWithFrame:(CGRect)frame image :(UIImage *) anImage title:(NSString *) title;

@end
