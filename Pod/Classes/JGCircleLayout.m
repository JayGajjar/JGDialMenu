//
//  JGCircleLayout.m
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import "JGCircleLayout.h"

typedef struct {
	CGFloat radius;
	CGFloat arc;
	CGFloat angle;
	NSUInteger offset;
	NSUInteger itemCount;
} JGCircleLayoutLayer;

JGCircleLayoutLayer JGCircleLayoutLayerMake(CGFloat radius, CGFloat arc, CGFloat angle, NSUInteger offset, NSUInteger itemCount);

@interface JGCircleLayout ()

@end

@implementation JGCircleLayout

- (id)initWithRadius:(CGFloat)radius arc:(CGFloat)arc angle:(CGFloat)angle minDistance:(CGFloat)minDistance {
	self = [self init];
	if (self) {
		self.radius = radius;
		self.arc = arc;
		self.angle = angle;
		self.minDistance = minDistance;
		self.uniformOuterLayer = NO;
	}
	return self;
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(JGMenu *)menu {
	NSUInteger itemCount = items.count;
	
	CGFloat radius = self.radius;
	CGFloat arc = self.arc;
	CGFloat angle = self.angle;
	CGFloat minDistance = self.minDistance;
	BOOL uniformOuterLayer = self.uniformOuterLayer;
	
	BOOL isFullCircle = ABS(arc) == DLWMFullCircle;
	
	CGFloat innerItemDistance = 0.0;
	CGFloat previousEndAngle = angle;
	
    NSUInteger offset = 0;
    
	NSUInteger layerIndex = 0;
	while (offset < itemCount) {
        JGCircleLayoutLayer layer = JGCircleLayoutLayerMake(radius, arc, angle, offset, itemCount - offset);
        
		NSUInteger maxItemCount = layer.itemCount;
		
		if (isFullCircle && !uniformOuterLayer) {
			layer.angle = previousEndAngle;
		}
		
		if (layerIndex > 0) {
			layer.radius = radius + (layerIndex * MIN(minDistance * 1.0, innerItemDistance * 1.1));
		}
		
		BOOL isOuterLayer;
		
        if (minDistance) {
            maxItemCount = round((layer.radius * ABS(layer.arc)) / minDistance);
            if (layer.arc == DLWMFullCircle) {
                maxItemCount--;
            }
            layer.itemCount = MIN(layer.itemCount, maxItemCount);
        }
        
        if (layerIndex == 0) {
            innerItemDistance = layer.radius * (ABS(layer.arc) / layer.itemCount);
        }
        
        isOuterLayer = (layer.itemCount == (itemCount - offset));
        
        if (isOuterLayer && layerIndex != 0 && !uniformOuterLayer) {
            layer.arc = (layer.arc / maxItemCount) * (layer.itemCount - 1);
        }
        
        layer.arc = MIN(ABS(layer.arc), [[self class] arcForFullCircleWithItemCount:layer.itemCount]);
        layer.arc = copysign(layer.arc, arc);
        
        layer.arc = MIN(ABS(layer.arc), [[self class] arcForFullCircleWithItemCount:layer.itemCount]);
        layer.arc = copysign(layer.arc, arc);
		
		previousEndAngle = layer.angle + layer.arc;
		
		NSArray *layerItems = [items subarrayWithRange:NSMakeRange(offset, layer.itemCount)];
		[self layoutItems:layerItems inArc:layer.arc fromAngle:layer.angle withRadius:layer.radius aroundCenterPoint:centerPoint inMenu:menu];
		
		offset += layer.itemCount;
		layerIndex++;
	}
}

- (void)layoutItems:(NSArray *)items inArc:(CGFloat)arc fromAngle:(CGFloat)angle withRadius:(CGFloat)radius aroundCenterPoint:(CGPoint)centerPoint inMenu:(JGMenu *)menu {
	NSUInteger itemCount = items.count;
	[items enumerateObjectsUsingBlock:^(JGMenuItem *item, NSUInteger index, BOOL *stop) {
		CGFloat itemAngle = [[self class] angleForItemAtIndex:index ofCount:itemCount inArc:arc startintAtAngle:angle];
		CGPoint itemCenter = CGPointMake(centerPoint.x + cosf(itemAngle) * radius,
										 centerPoint.y + sinf(itemAngle) * radius);
		item.layoutLocation = itemCenter;
	}];
}

+ (NSArray *)layoutItems:(NSArray *)items inArc:(CGFloat)arc fromAngle:(CGFloat)angle withRadius:(CGFloat)radius aroundCenterPoint:(CGPoint)centerPoint inMenu:(JGMenu *)menu {
    NSUInteger itemCount = items.count;
    NSMutableArray *itemCenterArr = [[NSMutableArray alloc] initWithArray:items];
    [items enumerateObjectsUsingBlock:^(JGMenuItem *item, NSUInteger index, BOOL *stop) {
        CGFloat itemAngle = [[self class] angleForItemAtIndex:index ofCount:itemCount inArc:arc startintAtAngle:angle];
        CGPoint itemCenter = CGPointMake(centerPoint.x + cosf(itemAngle) * radius,
                                         centerPoint.y + sinf(itemAngle) * radius);
//        item.layoutLocation = itemCenter;
        [itemCenterArr replaceObjectAtIndex:index withObject:NSStringFromCGPoint(itemCenter)];
    }];
    
    return itemCenterArr;
}


+ (CGFloat)arcForFullCircleWithItemCount:(NSUInteger)itemCount {
	return (DLWMFullCircle / MAX(1, itemCount)) * (itemCount - 1);
}

+ (CGFloat)angleForItemAtIndex:(NSUInteger)itemIndex ofCount:(NSUInteger)itemCount inArc:(CGFloat)arc startintAtAngle:(CGFloat)angle {
	return angle + (arc / MAX(1, itemCount - 1)) * itemIndex;
}

- (void)setRadius:(CGFloat)radius {
	_radius = radius;
	[self announceChange];
}

- (void)setArc:(CGFloat)arc {
	_arc = copysign(MIN(ABS(arc), DLWMFullCircle), arc);
	[self announceChange];
}

- (void)setAngle:(CGFloat)angle {
	_angle = fmod(angle, DLWMFullCircle);
	[self announceChange];
}

- (void)setMinDistance:(CGFloat)minDistance {
	_minDistance = minDistance;
	[self announceChange];
}

- (void)setUniformOuterLayer:(BOOL)uniformOuterLayer {
	_uniformOuterLayer = uniformOuterLayer;
	[self announceChange];
}

- (void)announceChange {
	[[NSNotificationCenter defaultCenter] postNotificationName:JGMenuLayoutChangedNotification object:self];
}

@end

JGCircleLayoutLayer JGCircleLayoutLayerMake(CGFloat radius, CGFloat arc, CGFloat angle, NSUInteger offset, NSUInteger itemCount) {
	return (JGCircleLayoutLayer){radius, arc, angle, offset, itemCount};
}
