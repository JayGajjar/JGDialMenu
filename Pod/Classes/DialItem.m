//
//  DialItem.m
//  JGDialMenu
//
//  Created by Jay on 10/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "DialItem.h"

@implementation DialItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame image :(UIImage *) anImage title:(NSString *) title{
    self = [super initWithFrame:frame];
    if (self) {
        image = anImage;
        titleStr = title;
    }
    return self;
    
}

-(void)drawRect:(CGRect)rect{
    [self commonInit];
}

-(void)commonInit{
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width-10, 10)];
    self.title.font = [UIFont systemFontOfSize:8];
    self.title.layer.cornerRadius = self.title.frame.size.height/2;
    self.title.layer.masksToBounds = YES;
    self.title.backgroundColor = [UIColor blackColor];
    self.title.textColor = [UIColor whiteColor];
    self.title.text = [NSString stringWithFormat:@"  %@  ",titleStr];
    //self.title.textAlignment = NSTextAlignmentCenter;
    [self.title sizeToFit];
    self.title.frame = CGRectMake((self.frame.size.width/2)-(self.title.frame.size.width/2), self.title.frame.origin.y, self.title.frame.size.width, self.title.frame.size.height);

    self.title.hidden = YES;
    if (titleStr.length <= 0) {
        self.title.hidden = YES;
        self.title.backgroundColor = [UIColor clearColor];
    }
    
    
    CGFloat h = MIN(self.frame.size.height - self.title.frame.size.height, self.frame.size.width);
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(((self.frame.size.width-h)/2), self.title.frame.size.height + self.title.frame.origin.y + 2, h, h)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = image;
    
    
    [self addSubview:self.imageView];
    [self addSubview:self.title];
}

@end
