//
//  JGMenu.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JGMenuItem.h"

extern const CGFloat DLWMFullCircle;

@class JGMenuAnimator;

@class JGMenu;

@protocol JGMenuDataSource <NSObject>

- (NSUInteger)numberOfObjectsInMenu:(JGMenu *)menu;
- (id)objectAtIndex:(NSUInteger)index inMenu:(JGMenu *)menu;

@end

@protocol JGMenuItemSource <NSObject>

- (UIView *)viewForObject:(id)object atIndex:(NSUInteger)index inMenu:(JGMenu *)menu;

@end

@protocol JGMenuItemDelegate <NSObject>

@optional

- (void)willOpenItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)willCloseItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration;

- (void)didOpenItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)didCloseItem:(JGMenuItem *)item inMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration;

@end

@protocol JGMenuDelegate <NSObject>

@optional

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer onItem:(JGMenuItem *)item inMenu:(JGMenu *)menu;
- (void)receivedDoubleTap:(UITapGestureRecognizer *)recognizer onItem:(JGMenuItem *)item inMenu:(JGMenu *)menu;
- (void)receivedLongPress:(UILongPressGestureRecognizer *)recognizer onItem:(JGMenuItem *)item inMenu:(JGMenu *)menu;
- (void)receivedPinch:(UIPinchGestureRecognizer *)recognizer onItem:(JGMenuItem *)item inMenu:(JGMenu *)menu;
- (void)receivedPan:(UIPanGestureRecognizer *)recognizer onItem:(JGMenuItem *)item inMenu:(JGMenu *)menu;

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer outsideOfMenu:(JGMenu *)menu;

- (void)willOpenMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)didOpenMenu:(JGMenu *)menu;

- (void)willCloseMenu:(JGMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)didCloseMenu:(JGMenu *)menu;

@end

extern NSString * const JGMenuLayoutChangedNotification;

@protocol JGMenuLayout <NSObject>

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(JGMenu *)menu;

@end

typedef void(^JGMenuAnimatorAnimationsBlock)(JGMenuItem *item, NSUInteger index, JGMenu *menu);
typedef void(^JGMenuAnimatorCompletionBlock)(JGMenuItem *item, NSUInteger index, JGMenu *menu, BOOL finished);

@protocol JGMenuAnimator <NSObject>

- (void)animateItem:(JGMenuItem *)item atIndex:(NSUInteger)index inMenu:(JGMenu *)menu animated:(BOOL)animated completion:(JGMenuAnimatorCompletionBlock)completion;

@end

typedef NS_OPTIONS(NSUInteger, JGMenuState) {
	JGMenuStateClosed  = (0x0 << 0),
	JGMenuStateClosing = (0x1 << 0),
	JGMenuStateOpening = (0x1 << 1),
	JGMenuStateOpened  = (0x1 << 2)
};

@interface JGMenu : UIView

@property (readonly, assign, nonatomic) CGPoint centerPointWhileOpen;
@property (readwrite, assign, nonatomic) CGPoint menuCenter;

@property (readonly, strong, nonatomic) JGMenuItem *mainItem;
@property (readonly, strong, nonatomic) NSArray *items;

@property (readwrite, weak, nonatomic) id<JGMenuDataSource> dataSource;
@property (readwrite, weak, nonatomic) id<JGMenuItemSource> itemSource;
@property (readwrite, weak, nonatomic) id<JGMenuDelegate> delegate;
@property (readwrite, weak, nonatomic) id<JGMenuItemDelegate> itemDelegate;

@property (readwrite, strong, nonatomic) id<JGMenuLayout> layout;

@property (readwrite, strong, nonatomic) id<JGMenuAnimator> openAnimator;
@property (readwrite, strong, nonatomic) id<JGMenuAnimator> closeAnimator;

@property (readwrite, assign, nonatomic) JGMenuState state;

@property (readwrite, assign, nonatomic) BOOL enabled;
@property (readwrite, assign, nonatomic) BOOL debuggingEnabled;

@property (readwrite, strong, nonatomic) id representedObject;

@property (readwrite, assign, nonatomic) NSTimeInterval openAnimationDelayBetweenItems;
@property (readwrite, assign, nonatomic) NSTimeInterval closeAnimationDelayBetweenItems;

- (id)initWithMainItemView:(UIView *)mainItemView
                dataSource:(id<JGMenuDataSource>)dataSource
                itemSource:(id<JGMenuItemSource>)itemSource
                  delegate:(id<JGMenuDelegate>)delegate
              itemDelegate:(id<JGMenuItemDelegate>)itemDelegate
                    layout:(id<JGMenuLayout>)layout
         representedObject:(id)representedObject
                    menuCenter:(CGPoint)menuCenter;


- (void)reloadData;

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated;

- (BOOL)isClosed;
- (BOOL)isClosing;
- (BOOL)isClosedOrClosing;

- (BOOL)isOpened;
- (BOOL)isOpening;
- (BOOL)isOpenedOrOpening;

- (BOOL)isAnimating;

- (void)open;
- (void)openAnimated:(BOOL)animated;

- (void)close;
- (void)closeAnimated:(BOOL)animated;

- (void)closeWithSpecialAnimator:(JGMenuAnimator *)itemAnimator forItem:(JGMenuItem *)item;
- (void)closeWithSpecialAnimator:(JGMenuAnimator *)itemAnimator forItem:(JGMenuItem *)item animated:(BOOL)animated;

- (void)moveTo:(CGPoint)centerPoint;
- (void)moveTo:(CGPoint)centerPoint animated:(BOOL)animated;

- (NSUInteger)indexOfItem:(JGMenuItem *)item;

- (void)adjustGeometryForState:(JGMenuState)state ;

@end
