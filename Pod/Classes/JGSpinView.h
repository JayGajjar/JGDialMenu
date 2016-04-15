//
//  JGSpinView.h
//  JGDialMenu
//
//  Created by Jay on 08/12/15.
//  Copyright © 2015 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface JGSpinView : UIView {
    double angle;
    double angularVelocity;
    double drag;
    
    NSDate * lastTimerDate;
    CADisplayLink * displayTimer;
    CADisplayLink * displayTimer2;

    CGPoint initialPoint;
    double initialAngle;
    CGPoint previousPoints[2];
    NSDate * previousDates[2];
}

@property (readwrite) double angle;
@property (readwrite) double angularVelocity;
@property (readwrite) double drag;

- (void)startAnimating:(id)sender;
- (void)stopAnimating:(id)sender;
- (void)startOpenAnimating:(id)sender ;
- (void)stopOpenAnimating:(id)sender ;

@end
