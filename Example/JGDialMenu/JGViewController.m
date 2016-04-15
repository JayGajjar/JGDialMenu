//
//  ViewController.m
//  JGDialMenu
//
//  Created by Jay on 10/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#define RADIUS 100

#import "JGViewController.h"
#import "DialItem.h"
#import "JGCircleLayout.h"
#import "JGSelectedMenuAnimator.h"

@interface JGViewController ()<JGMenuDataSource, JGMenuItemSource, JGMenuDelegate, JGMenuItemDelegate>{
    NSMutableArray *datasource ;

}
@end

@implementation JGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    datasource = [@[@{
                        @"image":@"angry",
                        @"hover_image":@"angry",
                        @"name":@""
                        },
                    @{
                        @"image":@"grin",
                        @"hover_image":@"grin",
                        @"name":@""
                        },
                    @{
                        @"image":@"have a nice day",
                        @"hover_image":@"have a nice day",
                        @"name":@"Liked!"
                        },
                    @{
                        @"image":@"ka boom",
                        @"hover_image":@"ka boom",
                        @"name":@""
                        },
                    @{
                        @"image":@"kiss",
                        @"hover_image":@"kiss",
                        @"name":@""
                        },
                    @{
                        @"image":@"ninja",
                        @"hover_image":@"ninja",
                        @"name":@""
                        },
                    @{
                        @"image":@"on fire",
                        @"hover_image":@"on fire",
                        @"name":@""
                        },
                    @{
                        @"image":@"want",
                        @"hover_image":@"on fire",
                        @"name":@""
                        },
                    @{
                        @"image":@"we all gonna die",
                        @"hover_image":@"on fire",
                        @"name":@""
                        },
                    @{
                        @"image":@"wut",
                        @"hover_image":@"on fire",
                        @"name":@""
                        }
                    ]mutableCopy];
    [self addDial];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addDial{
    DialItem *menuCenter = [self viewForMainItemInMenu:nil image:[UIImage imageNamed:@"center"] title:@""];
    CGPoint centerPoint = CGPointMake((menuCenter.frame.size.width/2) + 5, self.view.frame.size.height - ((menuCenter.frame.size.height/2) + 5)) ;
    centerPoint = self.view.center;
    UIImage *imageselected = [UIImage imageNamed:@"open-smiles"];
    UIImage *imageunselected = [UIImage imageNamed:@"big-like"];

    JGCircleLayout *layout = [[JGCircleLayout alloc] initWithRadius:RADIUS arc:DLWMFullCircle angle:M_PI_2 * 3 minDistance:0];
    _wheel = [[JGMenuDial alloc] initWithMainItemView:menuCenter
                                           dataSource:self
                                           itemSource:self
                                             delegate:self
                                         itemDelegate:self
                                               layout:layout
                                    representedObject:self
                                           menuCenter:centerPoint
                                    centerButtonImage:imageunselected
                            centerButtonSelectedImage:imageselected];
    
    [self.view addSubview:_wheel];
    [self.view addSubview:_wheel.centerButton];
}

- (DialItem *)viewForMainItemInMenu:(JGMenu *)menu image:(UIImage *) image title:(NSString *) title{
    //DialItem *item = [[[NSBundle mainBundle] loadNibNamed:@"DialItem" owner:self options:nil] firstObject];
    CGFloat size = 60;
    DialItem *item = [[DialItem alloc] initWithFrame:CGRectMake(0, 0, size, size) image:image title:title];
    item.backgroundColor = [UIColor clearColor];
    item.title.hidden = YES;
    item.frame = CGRectMake(0, 0, size, size);

    return item;
}

#pragma mark - JGMenuDataSource Protocol

- (NSUInteger)numberOfObjectsInMenu:(JGMenu *)menu {
    return datasource.count;
}

- (id)objectAtIndex:(NSUInteger)index inMenu:(JGMenu *)menu {
    return @(index);
}
#pragma mark - JGMenuItemSource Protocol

- (UIView *)viewForObject:(id)object atIndex:(NSUInteger)index inMenu:(JGMenu *)menu {
    NSDictionary *dataDict = [datasource objectAtIndex:index];
    UIImage *image = [UIImage imageNamed:[dataDict valueForKey:@"image"]];
    NSString *title = [dataDict valueForKey:@"name"];
    DialItem *item = [self viewForMainItemInMenu:nil image:image title:title];
    item.tag = index;
    item.imageView.image = image;
    item.title.text = title;
    return item;
}

#pragma mark - JGMenuItemDelegate Protocol

- (void)willOpenItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration {
    //    NSLog(@"%s", __FUNCTION__);
}

- (void)willCloseItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration {
    //    NSLog(@"%s", __FUNCTION__);
}

- (void)didOpenItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration {
    //    NSLog(@"%s", __FUNCTION__);
}

- (void)didCloseItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration {
    //    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - JGMenuDelegate Protocol

- (void)receivedLongPress:(UILongPressGestureRecognizer *)recognizer onItem:(JGMenuItem *)item inMenu:(JGMenu *)menu {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        JGCircleLayout *layout = (JGCircleLayout *)_wheel.menu.layout;
        NSUInteger itemIndex = [_wheel.menu indexOfItem:item];
        CGFloat arc = [JGCircleLayout arcForFullCircleWithItemCount:_wheel.menu.items.count];
        NSArray *arr = [JGCircleLayout layoutItems:_wheel.menu.items inArc:arc fromAngle:layout.angle withRadius:layout.radius + 35 aroundCenterPoint:_wheel.menu.centerPointWhileOpen inMenu:_wheel.menu];
        item.center = CGPointFromString([arr objectAtIndex:itemIndex]);
        
        NSDictionary *dataDict = [datasource objectAtIndex:itemIndex];
        DialItem *menuItem = (DialItem *) item.contentView;
        menuItem.title.hidden = NO;
        menuItem.imageView.image = [UIImage imageNamed:[dataDict valueForKey:@"hover_image"]];
        menuItem.imageView.transform = CGAffineTransformScale(menuItem.transform, 1.5, 1.5);
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [_wheel.menu reloadData];
        [_wheel.menu reloadInputViews];
        
        CGPoint locaton = [recognizer locationInView:_wheel.menu];
        if (CGRectContainsPoint(item.frame, locaton)) {
            if ([menu isClosedOrClosing]) {
                [menu open];
            } else if ([menu isOpenedOrOpening]) {
                if (item == menu.mainItem) {
                    [menu close];
                } else {
                    [menu closeWithSpecialAnimator:nil forItem:item];
                }
            }
        }
        [_wheel changeCenterButtonImage];
    }
}

@end
