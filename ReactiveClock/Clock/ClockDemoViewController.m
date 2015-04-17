//
//  ClockDemoViewController.m
//  ReactiveClock
//
//  Created by TaiVuong on 4/16/15.
//  Copyright (c) 2015 Tai Vuong. All rights reserved.
//

#import "ClockDemoViewController.h"
#import <ReactiveCocoa.h>
#import "RCClockView.h"

@interface ClockDemoViewController ()

@property (nonatomic, weak) IBOutlet UIButton *resumeButton;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;

@property (nonatomic, weak) IBOutlet UITextField *hourTextField;
@property (nonatomic, weak) IBOutlet UITextField *minTextField;
@property (nonatomic, weak) IBOutlet UITextField *secTextField;

@property (nonatomic, weak) IBOutlet RCClockView *clockView;


@property (nonatomic, assign) NSInteger a;
@property (nonatomic, assign) NSInteger b;

@end

@implementation ClockDemoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self bindingTextFieldsToClock];
    
    [self bindingClockToTextFields];
    
    @weakify(self);
    [[self rac_signalForSelector:@selector(touchesEnded:withEvent:)] subscribeNext:^(id x) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
    
    self.resumeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.clockView resume];
        return [RACSignal empty];
    }];
    
    [[self.updateButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.clockView startWithCurrentTime];
    }];
}

- (void)bindingClockToTextFields {
    
    RAC(self.hourTextField, text) = [[RACObserve(self.clockView, hours) distinctUntilChanged] map:^id(NSNumber *hours) {
        return [hours stringValue];
    }];
    
    RAC(self.minTextField, text) = [[RACObserve(self.clockView, minutes) distinctUntilChanged] map:^id(NSNumber *mins) {
        return [mins stringValue];
    }];
    
    RAC(self.secTextField, text) = [[RACObserve(self.clockView, seconds) distinctUntilChanged] map:^id(NSNumber *seconds) {
        return [seconds stringValue];
    }];
}

- (void)bindingTextFieldsToClock {
    
    RAC(self.clockView, hours) = [[[self.hourTextField rac_textSignal] ignore:@""] throttle:2];
    RAC(self.clockView, minutes) = [[[self.minTextField rac_textSignal] ignore:@""] throttle:2];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {}

@end
