//
//  ClockView.h
//  clock
//
//  Created by Ignacio Enriquez Gutierrez on 1/31/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//  See the file License.txt for copying permission.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ClockView : UIView {

	CALayer *containerLayer;
	CALayer *hourHand;
	CALayer *minHand;
	CALayer *secHand;
	NSTimer *timer;

}

@property (assign, nonatomic) BOOL secHandContinuos;

@property (assign, nonatomic) NSInteger seconds;
@property (assign, nonatomic) NSInteger minutes;
@property (assign, nonatomic) NSInteger hours;

- (void)defaultSetup;
- (void)updateClock;

@end
