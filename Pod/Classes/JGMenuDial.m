//
//  JGMenuDial.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGMenuDial.h"
#import "JGCircleLayout.h"

@implementation JGMenuDial

-(instancetype)init{
    if ((self = [super init])) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {

    }
    
    return self;
}

-(id)initWithMainItemView:(UIView *)mainItemView dataSource:(id<JGMenuDataSource>)dataSource itemSource:(id<JGMenuItemSource>)itemSource delegate:(id<JGMenuDelegate>)delegate itemDelegate:(id<JGMenuItemDelegate>)itemDelegate layout:(id<JGMenuLayout>)layout representedObject:(id)representedObject menuCenter:(CGPoint)menuCenter centerButtonImage : (UIImage *)image centerButtonSelectedImage : (UIImage *)selectedimage{
    if ((self = [self init])) {
        _menu = [[JGMenu alloc] initWithMainItemView:mainItemView
                                                     dataSource:dataSource
                                                     itemSource:itemSource
                                                       delegate:delegate
                                                   itemDelegate:itemDelegate
                                                         layout:layout
                                              representedObject:representedObject
                                                     menuCenter:menuCenter];
        imageselected = selectedimage;
        imageunselected = image;
        _menu.openAnimationDelayBetweenItems = 0.01;
        _menu.closeAnimationDelayBetweenItems = 0.01;
        CGPoint centerPoint = CGPointMake(_menu.frame.size.height/2, _menu.frame.size.width/2);
        _menu.menuCenter = centerPoint;
        _menu.center = centerPoint;
        
        CGRect frame = CGRectMake(menuCenter.x - (_menu.frame.size.width/2) , menuCenter.y - (_menu.frame.size.height/2), _menu.frame.size.width, _menu.frame.size.height);
        self.frame = frame;
        [self addSubview:_menu];
        
        _centerButton = [[UIButton alloc]initWithFrame:CGRectMake(mainItemView.frame.origin.x, mainItemView.frame.origin.y, mainItemView.frame.size.width + 10, mainItemView.frame.size.height + 10)];
        UIButton *btn = [[UIButton alloc]initWithFrame:_centerButton.frame];
        [btn addTarget:self action:@selector(centerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.adjustsImageWhenHighlighted = YES;
//        [btn setImage:imageselected forState:UIControlStateNormal];
//        [btn setImage:imageunselected forState:UIControlStateSelected]
        
        bgImg = [[UIImageView alloc]initWithFrame:_centerButton.frame];
        bgImg.image = imageunselected;
        _centerButton.center = self.center;
        [_centerButton addSubview:bgImg];
        [_centerButton addSubview:btn];
        

        [self startAnimating:self];
        [self setDrag:1];
    }
    return self;

}

- (void)setAngle:(double)anAngle {
    [super setAngle:anAngle];
    [[_menu layer] setTransform:CATransform3DMakeRotation(angle, 0, 0, 1)];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AngleChangeNotification" object:[NSNumber numberWithDouble:angle]];

//    NSLog(@"Angele : %f",fabs(angle));
//    ((JGCircleLayout *) menu.layout).radius = fabs(angle * 3);

}

-(IBAction)centerButtonAction:(id)sender{
    [self.menu reloadData];
    if (self.menu.isClosed) {
        [self.menu openAnimated:YES];
        self.angularVelocity = 3;
        [self startOpenAnimating:self];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopOpenAnimating:self];
        });
        [self changeCenterButtonImage];

    }else{
        self.angularVelocity = 0;
        [self.menu closeAnimated:YES];
        [self changeCenterButtonImage];

    }
}

-(void)changeCenterButtonImage{
    if (self.menu.isClosedOrClosing) {
        bgImg.image = imageunselected;

    }else{
        bgImg.image = imageselected;

    }
}


@end
