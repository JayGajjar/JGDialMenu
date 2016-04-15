//
//  JGMenuDial.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//


#import "JGSpinView.h"
#import "JGMenu.h"
@interface JGMenuDial : JGSpinView {
    UIImageView *bgImg;
    UIImage *imageselected;
    UIImage *imageunselected;
}

@property(nonatomic,retain) JGMenu *menu;
@property(nonatomic,retain) UIView *centerButton;

- (id)initWithMainItemView:(UIView *)mainItemView
         dataSource:(id<JGMenuDataSource>)dataSource
         itemSource:(id<JGMenuItemSource>)itemSource
           delegate:(id<JGMenuDelegate>)delegate
       itemDelegate:(id<JGMenuItemDelegate>)itemDelegate
             layout:(id<JGMenuLayout>)layout
  representedObject:(id)representedObject
         menuCenter:(CGPoint)menuCenter
        centerButtonImage : (UIImage *)image
centerButtonSelectedImage : (UIImage *)selectedimage;

-(void)changeCenterButtonImage;
@end
