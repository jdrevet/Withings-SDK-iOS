//
//  WithingsSleepMeasure.m
//  Withings-SDK-iOS
//
//  Created by Robert Turrall on 09/06/16.
//  Copyright © 2016 robertturrall. All rights reserved.
//

#import "WithingsSleepMeasure.h"

@implementation WithingsSleepMeasure

- (NSString*)description
{
    return [NSString stringWithFormat:@"WithingsSleepMeasure description:%@\r startdate: %@\renddate: %@\rstate: %@\r",[super description], self.startdate, self.enddate, [self stateToString]];
}

- (NSString*)stateToString {
    NSString *result = nil;
    
    switch(self.state) {
        case WithingsSleepStateAwake:
            result = @"Awake";
            break;
        case WithingsSleepStateLightSleep:
            result = @"Light Sleep";
            break;
        case WithingsSleepStateDeepSleep:
            result = @"Deep Sleep";
            break;
        case WithingsSleepStateREM:
            result = @"REM Sleep";
            break;

        default:
            result = @"unknown";
    }
    
    return result;
}
@end
