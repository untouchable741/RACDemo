//
//  RCClockView.m
//  ReactiveClock
//
//  Created by TaiVuong on 4/16/15.
//  Copyright (c) 2015 Tai Vuong. All rights reserved.
//

#import "RCClockView.h"
#import <ReactiveCocoa.h>

@interface RCClockView ()

@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation RCClockView

- (void)setupMergingSignal {
    
    [[RACSignal merge:@[[self hourChangedSignal],
                        [self minuteChangedSignal],
                        [self secondChangedSignal]]]
     subscribeNext:^(id x) {
        [self updateClock];
    }];
}

//- (void)setHours:(NSInteger)hours {
//    _hours = hours;
//    [self updateClock];
//}
//
//- (void)setMinutes:(NSInteger)minutes {
//    _minutes = minutes;
//    [self updateClock];
//}
//
//- (void)setSeconds:(NSInteger)seconds {
//    _seconds = seconds;
//    [self updateClock];
//}

- (void)defaultSetup {
    
    [super defaultSetup];
    
    [self setupMergingSignal];
    
    [self startWithCurrentTime];
}

- (void)startWithCurrentTime {
    
    if (self.disposable) {
        [self.disposable dispose];
    }
    
    [[[self getCurrentTimeSignal] doCompleted:^{
         [self startIntervalSignal];
     }]
     subscribeNext:^(RACTuple *x) {
        
        self.hours = [x.first integerValue];
        self.minutes = [x.second integerValue];
        self.seconds = [x.third integerValue];
    }];
}

- (void)resume {
    if (self.disposable) {
        [self.disposable dispose];
    }
    [self startIntervalSignal];
}

- (RACSignal *)getCurrentTimeSignal {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                                           fromDate:[NSDate date]];
        
        NSInteger seconds = [dateComponents second];
        NSInteger minutes = [dateComponents minute];
        NSInteger hours = [dateComponents hour];
        
        if (hours > 12) hours -=12;
        
        [subscriber sendNext:RACTuplePack(@(hours), @(minutes), @(seconds))];
        [subscriber sendCompleted];
        
        return nil;
    }];
}

- (void)startIntervalSignal {
    
    self.disposable = [[[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]]
      takeUntil:[self touchClockSignal]]
     subscribeNext:^(id x) {
         self.seconds++;
     } completed:^{
         NSLog(@"Interval signal completed");
     }];
}

- (RACSignal *)hourChangedSignal {
    
    return [RACObserve(self, hours) map:^id(NSNumber *hours) {
        if (hours.integerValue > 12) {
            return @(self.hours - 12);
        }
        return hours;
    }];
}

- (RACSignal *)minuteChangedSignal {
    
    return [RACObserve(self, minutes) map:^id(NSNumber *minutes) {
        
        if (minutes.integerValue >= 60) {
            self.hours++;
            self.minutes = 0;
            return @(self.minutes);
        }
        return minutes;
    }];
}

- (RACSignal *)secondChangedSignal {
    
    return [RACObserve(self, seconds) map:^id(NSNumber *seconds) {
        if (seconds.integerValue >= 60) {
            self.minutes++;
            self.seconds = 0;
            return @(self.seconds);
        }
        return seconds;
    }];
}

- (RACSignal *)touchClockSignal {
    return [self rac_signalForSelector:@selector(touchesBegan:withEvent:)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}

@end
