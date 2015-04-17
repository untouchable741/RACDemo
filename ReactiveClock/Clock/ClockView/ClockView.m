//
//  ClockView.m
//  clock
//
//  Created by Ignacio Enriquez Gutierrez on 1/31/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//  See the file License.txt for copying permission.
//

#import "ClockView.h"

@implementation ClockView

#pragma mark - Private Methods
//Default sizes of hands:
//in percentage (0.0 - 1.0)
#define HOURS_HAND_LENGTH 0.65
#define MIN_HAND_LENGTH 0.75
#define SEC_HAND_LENGTH 0.8
//in pixels
#define HOURS_HAND_WIDTH 3
#define MIN_HAND_WIDTH 3
#define SEC_HAND_WIDTH 3

float Degrees2Radians(float degrees) { return degrees * M_PI / 180; }

- (void)updateClock {
    
    CGFloat secAngle = Degrees2Radians(self.seconds/60.0*360);
    CGFloat minAngle = Degrees2Radians(self.minutes/60.0*360);
    CGFloat hourAngle = Degrees2Radians(self.hours/12.0*360) + minAngle/12.0;
    
    if (self.secHandContinuos) {
        CGFloat prevSecAngle = Degrees2Radians((self.seconds -1)/60.0*360);
        [secHand removeAnimationForKey:@"transform"];
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform"];
        ani.duration = 1.f;
        ani.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(prevSecAngle+M_PI, 0, 0, 1)];
        ani.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(secAngle+M_PI, 0, 0, 1)];
        [secHand addAnimation:ani forKey:@"transform"];
    } else {
        secHand.transform = CATransform3DMakeRotation (secAngle+M_PI, 0, 0, 1);
    }
    minHand.transform = CATransform3DMakeRotation (minAngle+M_PI, 0, 0, 1);
    hourHand.transform = CATransform3DMakeRotation (hourAngle+M_PI, 0, 0, 1);

}

- (void)defaultSetup
{
    containerLayer = [CALayer layer];
    hourHand = [CALayer layer];
    minHand = [CALayer layer];
    secHand = [CALayer layer];
    
    //default appearance
    [self setClockBackgroundImage:NULL];
    [self setHourHandImage:NULL];
    [self setMinHandImage:NULL];
    [self setSecHandImage:NULL];
    
    //add all created sublayers
    [containerLayer addSublayer:hourHand];
    [containerLayer addSublayer:minHand];
    [containerLayer addSublayer:secHand];
    [self.layer addSublayer:containerLayer];
    
    [self setClockBackgroundImage:[UIImage imageNamed:@"clockface"].CGImage];
}

#pragma mark - Overrides

- (void) layoutSubviews
{
	[super layoutSubviews];

	containerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

	float length = MIN(self.frame.size.width, self.frame.size.height)/2;
	CGPoint c = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	hourHand.position = minHand.position = secHand.position = c;

	CGFloat w, h;
	CGFloat scale = 1;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		scale = [UIScreen mainScreen].scale;
	}
	
	if (hourHand.contents == NULL){
		w = HOURS_HAND_WIDTH;
		h = length*HOURS_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((__bridge CGImageRef)hourHand.contents)/scale;
		h = CGImageGetHeight((__bridge CGImageRef)hourHand.contents)/scale;
	}
	hourHand.bounds = CGRectMake(0,0,w,h);
	
	if (minHand.contents == NULL){
		w = MIN_HAND_WIDTH;
		h = length*MIN_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((__bridge CGImageRef)minHand.contents)/scale;
		h = CGImageGetHeight((__bridge CGImageRef)minHand.contents)/scale;
	}
	minHand.bounds = CGRectMake(0,0,w,h);
	
	if (secHand.contents == NULL){
		w = SEC_HAND_WIDTH;
		h = length*SEC_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((__bridge CGImageRef)secHand.contents)/scale;
		h = CGImageGetHeight((__bridge CGImageRef)secHand.contents)/scale;
	}
	secHand.bounds = CGRectMake(0,0,w,h);

	hourHand.anchorPoint = CGPointMake(0.5,0.0);
	minHand.anchorPoint = CGPointMake(0.5,0.0);
	secHand.anchorPoint = CGPointMake(0.5,0.0);
	containerLayer.anchorPoint = CGPointMake(0.5, 0.5);
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self defaultSetup];
	}
	return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self defaultSetup];
}

//customize appearence
- (void)setHourHandImage:(CGImageRef)image
{
    if (image == NULL) {
        hourHand.backgroundColor = [UIColor redColor].CGColor;
        hourHand.cornerRadius = 3;
    }else{
        hourHand.backgroundColor = [UIColor clearColor].CGColor;
        hourHand.cornerRadius = 0.0;
        
    }
    hourHand.contents = (__bridge id)image;
}

- (void)setMinHandImage:(CGImageRef)image
{
    if (image == NULL) {
        minHand.backgroundColor = [UIColor greenColor].CGColor;
    }else{
        minHand.backgroundColor = [UIColor clearColor].CGColor;
    }
    minHand.contents = (__bridge id)image;
}

- (void)setSecHandImage:(CGImageRef)image
{
    if (image == NULL) {
        secHand.backgroundColor = [UIColor blueColor].CGColor;
        secHand.borderWidth = 1.0;
        secHand.borderColor = [UIColor grayColor].CGColor;
    }else{
        secHand.backgroundColor = [UIColor clearColor].CGColor;
        secHand.borderWidth = 0.0;
        secHand.borderColor = [UIColor clearColor].CGColor;
    }
    secHand.contents = (__bridge id)image;
}

- (void)setClockBackgroundImage:(CGImageRef)image
{
    if (image == NULL) {
        containerLayer.borderColor = [UIColor blackColor].CGColor;
        containerLayer.borderWidth = 1.0;
        containerLayer.cornerRadius = 5.0;
    }else{
        containerLayer.borderColor = [UIColor clearColor].CGColor;
        containerLayer.borderWidth = 0.0;
        containerLayer.cornerRadius = 0.0;
    }
    containerLayer.contents = (__bridge id)image;
}

@end