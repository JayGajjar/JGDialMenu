//
//  JGMenu.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGMenu.h"

#import "JGMenuItem.h"
#import "JGMenuAnimator.h"
#import "JGpringMenuAnimator.h"
#import "JGCircleLayout.h"

const CGFloat DLWMFullCircle = M_PI * 2;

NSString * const JGMenuLayoutChangedNotification = @"JGMenuLayoutChangedNotification";

@interface JGMenu ()

@property (readwrite, assign, nonatomic) CGPoint centerPointWhileOpen;

@property (readwrite, strong, nonatomic) JGMenuItem *mainItem;
@property (readwrite, strong, nonatomic) NSArray *items;

@property (readwrite, strong, nonatomic) NSTimer *timer;

@end

@implementation JGMenu

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		if (![self commonInit_JGMenu]) {
			return nil;
		}
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		if (![self commonInit_JGMenu]) {
			return nil;
		}
	}
	return self;
}

- (BOOL)commonInit_JGMenu {
	self.items = [NSMutableArray array];
	
	self.enabled = YES;
	
    JGMenuAnimator * openAnimator = nil;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        openAnimator = [JGMenuAnimator new];
    } else {
        openAnimator = [JGpringMenuAnimator new];
    }

	self.openAnimator = openAnimator;
	self.closeAnimator = [[JGMenuAnimator alloc] init];
	self.openAnimationDelayBetweenItems = 0.025;
	self.closeAnimationDelayBetweenItems = 0.025;
	
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedSingleTapOutside:)];
	[self addGestureRecognizer:singleTapRecognizer];
	
	return YES;
}

- (id)initWithMainItemView:(UIView *)mainItemView
                dataSource:(id<JGMenuDataSource>)dataSource
                itemSource:(id<JGMenuItemSource>)itemSource
                  delegate:(id<JGMenuDelegate>)delegate
              itemDelegate:(id<JGMenuItemDelegate>)itemDelegate
                    layout:(id<JGMenuLayout>)layout
         representedObject:(id)representedObject
         menuCenter:(CGPoint)menuCenter{
    self = [self initWithFrame:mainItemView.frame];
    if (self) {
        NSAssert(dataSource, @"Method argument 'dataSource' must not be nil.");
        NSAssert(itemSource, @"Method argument 'itemSource' must not be nil.");
        NSAssert(layout, @"Method argument 'layout' must not be nil.");
        self.state = JGMenuStateClosed;
        self.representedObject = representedObject;
        self.centerPointWhileOpen = mainItemView.center;
        self.mainItem = [[JGMenuItem alloc] initWithContentView:mainItemView representedObject:representedObject];
        self.dataSource = dataSource;
        self.itemSource = itemSource;
        self.delegate = delegate;
        self.itemDelegate = itemDelegate;
        self.layout = layout;
        self.menuCenter = menuCenter;
        
        [self reloadData];
        [self adjustGeometryForState:JGMenuStateClosed];
    }
    return self;
}

- (void)adjustGeometryForState:(JGMenuState)state {
	CGPoint itemLocation;
	if (state == JGMenuStateClosed) {
		CGRect itemBounds = self.mainItem.bounds;
		itemLocation = CGPointMake(CGRectGetMidX(itemBounds), CGRectGetMidY(itemBounds));
		CGPoint menuCenter = self.mainItem.center;
		self.bounds = itemBounds;
		self.center = menuCenter;
	} else {
//		CGRect menuFrame = self.superview.bounds;
//		itemLocation = self.center;
//		self.frame = menuFrame;
	}
    CGFloat radius = 0;
    if ([self.layout isKindOfClass:[JGCircleLayout class]]) {
        JGCircleLayout *layout = (JGCircleLayout *)self.layout;
        radius = [JGMenu pixelToPoints:layout.radius];
    }

    CGRect itemBounds = self.mainItem.bounds;
    itemBounds.size.height = (itemBounds.size.height*3) + radius;
    itemBounds.size.width = itemBounds.size.height;
    itemLocation = CGPointMake(CGRectGetMidX(itemBounds), CGRectGetMidY(itemBounds));
    self.bounds = itemBounds;

	self.mainItem.center = itemLocation;
	self.mainItem.layoutLocation = itemLocation;
	self.centerPointWhileOpen = itemLocation;
    self.center = self.menuCenter;

}

+(CGFloat)pixelToPoints:(CGFloat)px {
    CGFloat pointsPerInch = 72.0; // see: http://en.wikipedia.org/wiki/Point%5Fsize#Current%5FDTP%5Fpoint%5Fsystem
    CGFloat scale = 1; // We dont't use [[UIScreen mainScreen] scale] as we don't want the native pixel, we want pixels for UIFont - it does the retina scaling for us
    float pixelPerInch; // aka dpi
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pixelPerInch = 132 * scale;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        pixelPerInch = 163 * scale;
    } else {
        pixelPerInch = 160 * scale;
    }
    CGFloat result = px * pointsPerInch / pixelPerInch;
    return result;
}

#pragma mark - Custom Accessors

- (void)setMainItem:(JGMenuItem *)mainItem {
	NSAssert(mainItem, @"Method argument 'mainItem' must not be nil.");
	if (_mainItem) {
		[_mainItem removeFromSuperview];
		[self removeGestureRecognizersFromMenuItem:_mainItem];
	}
	_mainItem = mainItem;
	[self addGestureRecognizersToMenuItem:mainItem];
	mainItem.userInteractionEnabled = YES;
	mainItem.center = self.centerPointWhileOpen;
	[self addSubview:mainItem];
}

- (void)setDataSource:(id<JGMenuDataSource>)dataSource {
	NSAssert(dataSource, @"Method argument 'dataSource' must not be nil.");
	_dataSource = dataSource;
	[self reloadData];
}

- (void)setItemSource:(id<JGMenuItemSource>)itemSource {
	NSAssert(itemSource, @"Method argument 'itemSource' must not be nil.");
	_itemSource = itemSource;
	[self reloadData];
}

- (void)setLayout:(id<JGMenuLayout>)layout {
	NSAssert(layout, @"Method argument 'layout' must not be nil.");
	if (_layout) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:JGMenuLayoutChangedNotification object:_layout];
	}
	_layout = layout;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutDidChange:) name:JGMenuLayoutChangedNotification object:_layout];
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[self layoutItemsWithCenter:self.centerPointWhileOpen animated:YES];
	} completion:nil];
}

- (void)setEnabled:(BOOL)enabled {
	[self setEnabled:enabled animated:YES];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated {
	BOOL oldEnabled = _enabled;
	[self willChangeValueForKey:NSStringFromSelector(@selector(enabled))];
	_enabled = enabled;
	[self didChangeValueForKey:NSStringFromSelector(@selector(enabled))];
	
	if (enabled != oldEnabled) {
		NSTimeInterval duration = (animated) ? 0.5 : 0.0;
		[UIView animateWithDuration:duration animations:^{
			self.alpha = (enabled) ? 1.0 : 0.33;
		}];
	}
}

- (void)setDebuggingEnabled:(BOOL)debuggingEnabled {
	_debuggingEnabled = debuggingEnabled;
	self.backgroundColor = (debuggingEnabled) ? [[UIColor redColor] colorWithAlphaComponent:0.5] : nil;
}

#pragma mark - Observing

- (void)layoutDidChange:(NSNotification *)notification {
	[self layoutItemsWithCenter:self.centerPointWhileOpen animated:YES];
}

#pragma mark - Reloading

- (void)reloadData {
	id<JGMenuDataSource> dataSource = self.dataSource;
	id<JGMenuItemSource> itemSource = self.itemSource;
	NSUInteger itemCount = [dataSource numberOfObjectsInMenu:self];
	NSUInteger currentItemCount = self.items.count;
	NSUInteger minCount = MIN(itemCount, currentItemCount);
	
	// Remove all items not needed any more:
	if (itemCount < currentItemCount) {
		for (NSUInteger i = 0; i < currentItemCount - itemCount; i++) {
			[self removeLastItem];
		}
	}
	
	// Update existing items:
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, minCount)];
	[self.items enumerateObjectsAtIndexes:indexes options:0 usingBlock:^(JGMenuItem *item, NSUInteger index, BOOL *stop) {
		id object = [dataSource objectAtIndex:index inMenu:self];
		UIView *contentView = [itemSource viewForObject:object atIndex:index inMenu:self];
		item.contentView = contentView;
		item.representedObject = object;
	}];
	
	// Add all additional items:
	if (itemCount > currentItemCount) {
		for (NSUInteger i = currentItemCount; i < itemCount; i++) {
			id object = [dataSource objectAtIndex:i inMenu:self];
			UIView *contentView = [itemSource viewForObject:object atIndex:i inMenu:self];
			JGMenuItem *item = [[JGMenuItem alloc] initWithContentView:contentView representedObject:object];
			item.layoutLocation = [self isClosed] ? self.center : self.centerPointWhileOpen;
			[self addItem:item];
		}
	}
	[self layoutItemsWithCenter:self.centerPointWhileOpen animated:YES];
}

#pragma mark - Opening/Closing

- (void)open {
	[self openAnimated:YES];
}

- (void)openAnimated:(BOOL)animated {
	if ([self isOpenedOrOpening]) {
		return;
	}
	[self.timer invalidate];
	self.timer = nil;
	
	self.state = JGMenuStateOpening;
	[self adjustGeometryForState:self.state];
	
	NSArray *items = self.items;
	JGMenuAnimator *animator = self.openAnimator ?: [JGMenuAnimator sharedInstantAnimator];
	NSTimeInterval openAnimationDelayBetweenItems = self.openAnimationDelayBetweenItems;
	NSTimeInterval totalDuration = (items.count - 1) * openAnimationDelayBetweenItems + animator.duration;
	if ([self.delegate respondsToSelector:@selector(willOpenMenu:withDuration:)]) {
		[self.delegate willOpenMenu:self withDuration:totalDuration];
	}
	[self.layout layoutItems:items forCenterPoint:self.centerPointWhileOpen inMenu:self];
	[items enumerateObjectsUsingBlock:^(JGMenuItem *item, NSUInteger index, BOOL *stop) {
		double delayInSeconds = openAnimationDelayBetweenItems * index;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			if ([self.itemDelegate respondsToSelector:@selector(willOpenItem:inMenu:withDuration:)]) {
				[self.itemDelegate willOpenItem:item inMenu:self withDuration:animator.duration];
			}
			[animator animateItem:item atIndex:index inMenu:self animated:animated completion:^(JGMenuItem *menuItem, NSUInteger itemIndex, JGMenu *menu, BOOL finished) {
                if ([self.itemDelegate respondsToSelector:@selector(didOpenItem:inMenu:withDuration:)]) {
                    [self.itemDelegate didOpenItem:menuItem inMenu:self withDuration:animator.duration];
                }
            }];
		});
	}];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:totalDuration
												  target:self
												selector:@selector(handleDidOpenMenu:)
												userInfo:nil
												 repeats:NO];
}

- (void)handleDidOpenMenu:(NSTimer *)timer {
	self.timer = nil;
	self.state = JGMenuStateOpened;
	if ([self.delegate respondsToSelector:@selector(didOpenMenu:)]) {
		[self.delegate didOpenMenu:self];
	}
}

- (void)close {
	[self closeAnimated:YES];
}

- (void)closeAnimated:(BOOL)animated {
	[self closeWithSpecialAnimator:nil forItem:nil animated:animated];
}

- (void)closeWithSpecialAnimator:(JGMenuAnimator *)itemAnimator forItem:(JGMenuItem *)item {
	[self closeWithSpecialAnimator:itemAnimator forItem:item animated:YES];
}

- (void)closeWithSpecialAnimator:(JGMenuAnimator *)specialAnimator forItem:(JGMenuItem *)specialItem animated:(BOOL)animated {
	if ([self isClosedOrClosing]) {
		return;
	}
	[self.timer invalidate];
	self.timer = nil;
	if (specialItem == self.mainItem) {
		specialItem = nil;
	}
	NSArray *items = self.items;
	__block JGMenuAnimator *animator = self.closeAnimator ?: [JGMenuAnimator sharedInstantAnimator];
	NSTimeInterval closeAnimationDelayBetweenItems = self.closeAnimationDelayBetweenItems;
	NSTimeInterval totalDuration = (items.count - 1) * closeAnimationDelayBetweenItems + animator.duration;
	if ([self.delegate respondsToSelector:@selector(willCloseMenu:withDuration:)]) {
		[self.delegate willCloseMenu:self withDuration:totalDuration];
	}
	self.state = JGMenuStateClosing;
	if (specialItem) {
		// make sure special items is the first one being animated
		items = [@[specialItem] arrayByAddingObjectsFromArray:[self itemsWithoutItem:specialItem]];
	}
	[items enumerateObjectsUsingBlock:^(JGMenuItem *item, NSUInteger index, BOOL *stop) {
		JGMenuAnimator *itemAnimator = animator;
		if (item == specialItem) {
			itemAnimator = specialAnimator ?: [JGMenuAnimator sharedInstantAnimator];
		}
		double delayInSeconds = closeAnimationDelayBetweenItems * index;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			if ([self.itemDelegate respondsToSelector:@selector(willCloseItem:inMenu:withDuration:)]) {
				[self.itemDelegate willCloseItem:item inMenu:self withDuration:itemAnimator.duration];
			}
			[itemAnimator animateItem:item atIndex:index inMenu:self animated:animated completion:^(JGMenuItem *menuItem, NSUInteger itemIndex, JGMenu *menu, BOOL finished) {
                if ([self.itemDelegate respondsToSelector:@selector(didCloseItem:inMenu:withDuration:)]) {
                    [self.itemDelegate didCloseItem:menuItem inMenu:self withDuration:itemAnimator.duration];
                }
            }];
		});
	}];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:totalDuration
												  target:self
												selector:@selector(handleDidCloseMenu:)
												userInfo:nil
												 repeats:NO];
}

- (void)handleDidCloseMenu:(NSTimer *)timer {
	self.timer = nil;

	self.state = JGMenuStateClosed;
	[self adjustGeometryForState:self.state];
	
	if ([self.delegate respondsToSelector:@selector(didCloseMenu:)]) {
		[self.delegate didCloseMenu:self];
	}
}

- (NSArray *)itemsWithoutItem:(JGMenuItem *)item {
	NSArray *items = self.items;
	if (item) {
		items = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JGMenuItem *menuItem, NSDictionary *bindings) {
			return menuItem != item;
		}]];
	}
	return items;
}

#pragma mark - UIGestureRecognizer Handlers

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	return self.enabled;
}

- (void)receivedPinch:(UIPinchGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedPinch:onItem:inMenu:)]) {
		[self.delegate receivedPinch:recognizer onItem:(JGMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedPan:(UIPanGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedPan:onItem:inMenu:)]) {
		[self.delegate receivedPan:recognizer onItem:(JGMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedLongPress:(UILongPressGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedLongPress:onItem:inMenu:)]) {
		[self.delegate receivedLongPress:recognizer onItem:(JGMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedDoubleTap:(UITapGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedDoubleTap:onItem:inMenu:)]) {
		[self.delegate receivedDoubleTap:recognizer onItem:(JGMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedSingleTap:onItem:inMenu:)]) {
		[self.delegate receivedSingleTap:recognizer onItem:(JGMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedSingleTapOutside:(UITapGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedSingleTap:outsideOfMenu:)]) {
		[self.delegate receivedSingleTap:recognizer outsideOfMenu:self];
	}
}

#pragma mark - States

- (BOOL)isClosed {
	return self.state == JGMenuStateClosed;
}

- (BOOL)isClosing {
	return self.state == JGMenuStateClosing;
}

- (BOOL)isClosedOrClosing {
	return self.state == JGMenuStateClosed || self.state == JGMenuStateClosing;
}

- (BOOL)isOpened {
	return self.state == JGMenuStateOpened;
}

- (BOOL)isOpening {
	return self.state == JGMenuStateOpening;
}

- (BOOL)isOpenedOrOpening {
	return self.state == JGMenuStateOpened || self.state == JGMenuStateOpening;
}

- (BOOL)isAnimating {
	return self.state == JGMenuStateOpening || self.state == JGMenuStateClosing;
}

#pragma mark - Add/Remove Items

- (void)addGestureRecognizersToMenuItem:(JGMenuItem *)menuItem {
	NSAssert(menuItem, @"Method argument 'menuItem' must not be nil.");
	
	//UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(receivedPinch:)];
	//[menuItem addGestureRecognizer:pinchRecognizer];
	
	//UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(receivedPan:)];
	//[menuItem addGestureRecognizer:panRecognizer];
	
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(receivedLongPress:)];
    longPressRecognizer.minimumPressDuration = 0.1;
    longPressRecognizer.cancelsTouchesInView = NO;
	[menuItem addGestureRecognizer:longPressRecognizer];
	
	UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedDoubleTap:)];
	[doubleTapRecognizer setNumberOfTapsRequired:2];
	//[menuItem addGestureRecognizer:doubleTapRecognizer];
	
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedSingleTap:)];
	[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
	//[menuItem addGestureRecognizer:singleTapRecognizer];
}

- (void)removeGestureRecognizersFromMenuItem:(JGMenuItem *)menuItem {
	for (UIGestureRecognizer *recognizer in menuItem.gestureRecognizers) {
		[menuItem removeGestureRecognizer:recognizer];
	}
}

- (void)addItem:(JGMenuItem *)item {
	NSAssert(item, @"Method argument 'menuItem' must not be nil.");
	[((NSMutableArray *)self.items) addObject:item];
	[self addGestureRecognizersToMenuItem:item];
	item.userInteractionEnabled = YES;
	BOOL hidden = [self isClosed];
	item.hidden = hidden;
	if (!hidden) {
		item.alpha = 0.0;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			item.alpha = 1.0;
		} completion:nil];
	}
	item.center = self.centerPointWhileOpen;
	[self insertSubview:item belowSubview:self.mainItem];
}

- (void)removeItem:(JGMenuItem *)item {
	NSAssert(item, @"Method argument 'menuItem' must not be nil.");
	NSAssert(item.superview == self, @"Method argument 'menuItem' must be member of menu.");
	[item removeFromSuperview];
	[self removeGestureRecognizersFromMenuItem:item];
	[((NSMutableArray *)self.items) removeObject:item];
}

- (void)removeLastItem {
	JGMenuItem *item = [self.items lastObject];
	if (item) {
		[self removeItem:item];
	}
}

- (void)moveTo:(CGPoint)centerPoint {
	[self moveTo:centerPoint animated:YES];
}

- (void)moveTo:(CGPoint)centerPoint animated:(BOOL)animated {
	// Moving the items' layoutLocation so that layouts which
	// rely on an item's previous location can be supported.
	// A potential candidate would be a force-directed layout.
	[self layoutItemsWithCenter:centerPoint animated:animated];
    if ([self isClosed]) {
        NSTimeInterval duration = (animated) ? 0.5 : 0.0;
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.center = centerPoint;
        } completion:nil];
    } else {
        self.centerPointWhileOpen = centerPoint;
    }
}

- (void)layoutItemsWithCenter:(CGPoint)centerPoint animated:(BOOL)animated {
	NSArray *items = self.items;
	if (!items.count) {
		return;
	}
	[self.layout layoutItems:items forCenterPoint:centerPoint inMenu:self];
	if ([self isOpenedOrOpening]) {
        NSTimeInterval duration = (animated) ? 0.5 : 0.0;
		[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.mainItem.center = centerPoint;
            [items enumerateObjectsUsingBlock:^(JGMenuItem *item, NSUInteger index, BOOL *stop) {
                item.center = item.layoutLocation;
            }];
        } completion:nil];
	}
}

- (NSUInteger)indexOfItem:(JGMenuItem *)item {
	return [self.items indexOfObjectIdenticalTo:item];
}

@end
